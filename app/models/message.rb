class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id

  serialize :read_by
  
  belongs_to :user
  has_one :attachment
  has_many :incoming_receipts
  has_many :receivers, :through => :incoming_receipts, :source => :workstation
  has_one :outgoing_receipt
  has_many :acknowledgements
  has_many :readers, :through => :acknowledgements, :source => :user
  
  validates :content, :presence => true, :length => { :maximum => 300 }
  validates :user_id, :presence => true

  default_scope order("created_at DESC")
  
  def <=>(other)
    created_at <=> other.created_at
  end

  def as_json
    hash = {}
    hash[:id] = id
    hash[:content] = content
    hash[:created_at] = created_at.strftime("%a %b %e %Y %T")
    hash[:sender] = sender_handle if sender_handle
    attachment = Attachment.find(attachment_id) if Attachment.exists?(attachment_id)
    hash[:attachment_url] = attachment.payload.url if attachment
    hash[:view_class] = view_class if view_class
    hash[:readers] = formatted_readers if formatted_readers
    hash.as_json
  end

  def generate_incoming_receipts(options = {})
    user.recipients.each { |recipient| generate_incoming_receipt(recipient, options) }
  end

  def generate_incoming_receipt(workstation, options = {})
    incoming_receipts.create(workstation: workstation,
                             user: options[:user] || workstation.user,
                             attachment: options[:attachment])
  end

  def broadcast
    sent_to = []
    user.recipients.each do |recipient|
      if recipient.user
        unless sent_to.include?(recipient.user.id)
          sent_to << recipient.user.id

          new_recip_ids = user.workstation_ids.map do |workstation_id|
            recip = recipient.user.add_recipient(Workstation.find(workstation_id))
            recip ? recip.id : 0
          end

          data = { 
            chat_message: content,
            sender: user.handle,
            from_workstations: user.workstation_names,
            recipient_ids: new_recip_ids,
            timestamp: created_at.strftime("%a %b %e %Y %T"),
            message_id: id
          }
          attachment = Attachment.find(attachment_id) if Attachment.exists?(attachment_id)
          data[:attachment_url] = attachment.payload.url if attachment
 
          PrivatePub.publish_to("/messages/#{recipient.user.user_name}", data)
        end
      end
    end
  end

  def generate_outgoing_receipt
    create_outgoing_receipt(user: user, workstations: user.workstation_names)
  end

  def sender_handle
    "#{user.user_name}@#{sent_by_workstations_list}"
  end 
  
  def sent_by_workstations_list
    sent_by = ""
    if outgoing_receipt
      outgoing_receipt.workstations.each_with_index do |workstation_abrev, index|
        sent_by += "," unless index == 0
        sent_by += workstation_abrev
      end
    end
    sent_by
  end

  def sent_by?(user)
    user_id == user.id
  end

  def set_view_class(user)
    if sent_by?(user)
      self.view_class = "message msg-#{id} owner"
    end
    
    if sent_to?(user)
      if was_read_by?(user)
        self.view_class = "message msg-#{id} recieved read"
      else
        self.view_class = "message msg-#{id} recieved unread"
      end
    end
  end

  def mark_read_by(user)
    unless readers.include?(user)
      acknowledgements << Acknowledgement.new(user: user, workstation_ids: user.workstation_ids)
      save
    end
  end

  def formatted_readers
    readers_str = ""
    acknowledgements.each_with_index do |acknowledgement, index|
      workstations = acknowledgement.workstation_ids.map { |ws_id| Workstation.find(ws_id).abrev }.join(",")
      if index == (acknowledgements.size - 1) and (acknowledgements.size > 1)
        readers_str += " and " 
      elsif index > 0
        readers_str += ", "
      end
      user = acknowledgement.user
      readers_str += "#{user.user_name}@#{workstations}"
    end
    readers_str += " read this." unless readers_str.blank?
    readers_str
  end

  def sent_to?(user)
    sent_to = false
    incoming_receipts.each do |receipt|
      if receipt.user_id == user.id or (user.workstations.include?(receipt.workstation) and receipt.user.nil?)
        sent_to = true
        break
      end
    end
    sent_to
  end

  def was_read_by?(user)
    readers.include?(user)
  end
end

