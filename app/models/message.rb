class Message < ActiveRecord::Base

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

          PrivatePub.publish_to("/messages/#{recipient.user.user_name}",
                                MessagePresenter.new(self, recipient.user).as_json)
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

  def attach(attachment)
    self.attachment = attachment
    save
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

  def generate_view_class(user)
    view_class = ""
    if sent_by?(user)
      view_class = "message msg-#{id} owner"
    elsif sent_to?(user)
      if was_read_by?(user)
        view_class = "message msg-#{id} recieved read"
     else
        view_class = "message msg-#{id} recieved unread"
      end
    end
    view_class
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

