class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id

  serialize :read_by
  
  belongs_to :user
  has_many :receivers
  has_many :sender_workstations
  has_many :receipts
  has_many :readers, :through => :receipts, :source => :user
  
  validates :content, :presence => true, :length => { :maximum => 300 }
  validates :user_id, :presence => true

  default_scope order("created_at DESC")

  scope :between, lambda { |timeFrom, timeTo|
    where("messages.created_at >= ? and messages.created_at <= ?", timeFrom, timeTo)
  }

  scope :before, lambda { |time| between(time - 24.hours, time) }

  scope :sent_by_user, lambda { |user_id|
    where("messages.user_id = ?", user_id)
  }

  scope :sent_to_user, lambda { |user_id|
    joins(:receivers).where("receivers.user_id = ?", user_id)
  }

  scope :sent_to_workstation, lambda { |workstation_id|
    joins(:receivers).where("receivers.workstation_id = ? and receivers.user_id is null", workstation_id)
  }

  scope :sent_to_workstations, lambda { |workstation_ids|
    joins(:receivers).where("receivers.workstation_id in (#{workstation_ids.join(",")}) and receivers.user_id is null")
  }

  scope :sent_to_user_or_workstations, lambda { |user_id, workstation_ids|
    sent_to_user(user_id).or(sent_to_workstations(workstation_ids))
  }

  def self.for_user_before(user, time)
    if (user.workstation_ids.blank?)
      messages = Message.sent_by_user(user.id).before(time) |
        Message.sent_to_user(user.id).before(time)
    else
      messages = Message.sent_by_user(user.id).before(time) |
        Message.sent_to_user_or_workstations(user.id, user.workstation_ids).before(time)
    end
    messages.sort.reverse
  end

  def self.for_user_between(user, timeFrom, timeTo)
    if (user.workstation_ids.blank?)
      messages = Message.sent_by_user(user.id).between(timeFrom, timeTo) |
        Message.sent_to_user(user.id).between(timeFrom, timeTo)
    else
      messages = Message.sent_by_user(user.id).between(timeFrom, timeTo) |
        Message.sent_to_user_or_workstations(user.id, user.workstation_ids).between(timeFrom, timeTo)
    end
    messages.sort.reverse
  end

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
    hash[:readers] = readers if readers
    hash.as_json
  end

  def set_receivers
    user.recipients.each do |recipient|
      workstation = Workstation.find_by_id(recipient.workstation_id)
      set_received_by(workstation)
    end
  end

  def set_received_by(workstation)
    receiver = self.receivers.new
    receiver.workstation = workstation
    recip_user = User.find_by_id(workstation.user_id)
    receiver.user = recip_user if recip_user
    receiver.save
  end

  def broadcast
    user = User.find(user_id)
    sent_to = []
    user.recipients.each do |recipient|
      workstation = Workstation.find(recipient.workstation_id)
      if User.exists?(workstation.user_id)
        recip_user = User.find(workstation.user_id) 
        unless sent_to.include?(recip_user.id)
          sent_to << recip_user.id

          new_recip_ids = user.workstation_ids.map do |workstation_id|
            recip = recip_user.add_recipient(Workstation.find(workstation_id))
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
 
          PrivatePub.publish_to("/messages/#{recip_user.user_name}", data)
        end
      end
    end
  end

  def set_sender_workstations
    user.workstations.each do |workstation|
      sender_workstation = self.sender_workstations.new
      sender_workstation.workstation = workstation    
      sender_workstation.save
    end
  end

  def sender_handle
    "#{user.user_name}@#{sent_by}"
  end 
  
  def sent_by
    sent_by = ""
    self.sender_workstations.each_index do |index|
      sent_by += "," unless index == 0
      sent_by += sender_workstations[index].workstation.abrev
    end
    sent_by
  end

  def was_sent_by?(user)
    if self.user_id == user.id
      true
    else
      false
    end
  end

  def set_view_class(user)
    if was_sent_by?(user)
      self.view_class = "message msg-#{id} owner"
    end
    
    if was_sent_to?(user)
      if was_read_by?(user)
        self.view_class = "message msg-#{id} recieved read"
      else
        self.view_class = "message msg-#{id} recieved unread"
      end
    end
  end

  def mark_read_by(user)
    unless readers.include?(user)
      receipts << Receipt.new(user: user, workstation_ids: user.workstation_ids)
      save
    end
  end

  def formatted_readers
    readers_str = ""
    receipts.each_with_index do |receipt, index|
      workstations = receipt.workstation_ids.map { |ws_id| Workstation.find(ws_id).abrev }.join(",")
      if index == (receipts.size - 1) and (receipts.size > 1)
        readers_str += " and " 
      elsif index > 0
        readers_str += ", "
      end
      user = receipt.user
      readers_str += "#{user.user_name}@#{workstations}"
    end
    readers_str += " read this." unless readers_str.blank?
    readers_str
  end

  def was_sent_to?(user)
    sent_to = false
    self.receivers.each do |receiver|
      if receiver.user_id == user.id or (user.workstation_ids.include?(receiver.workstation_id) and receiver.user.nil?)
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

