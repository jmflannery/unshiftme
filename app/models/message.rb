class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id

  serialize :read_by
  
  belongs_to :user
  has_many :receivers
  has_many :sender_workstations
  
  validates :content, :presence => true, :length => { :maximum => 300 }
  validates :user_id, :presence => true

  default_scope order("created_at DESC")

  scope :before, lambda { |time|
    where("messages.created_at >= ? and messages.created_at <= ?", time - 24.hours, time)
  }
  scope :between, lambda { |timeFrom, timeTo|
    where("messages.created_at >= ? and messages.created_at <= ?", timeFrom, timeTo)
  }
  scope :sent_to, lambda { |user_id|
    joins("inner join receivers on receivers.message_id = messages.id").where("receivers.user_id = ?", user_id)
  }

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
            message_id: id.to_s
          }
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

  def self.for_user_before(user, time)
    messages = []
    before(time).each do |message|
      if message.was_sent_by?(user) or message.was_sent_to?(user)
        messages << message
      end
    end
    messages
  end

  def self.for_user_between(user, timeFrom, timeTo)
    messages = []
    between(timeFrom, timeTo).each do |message|
      if message.was_sent_by?(user) or message.was_sent_to?(user)
        messages << message
      end
    end
    messages
  end

  def set_view_class(current_user)
    if was_sent_by?(current_user)
      self.view_class = "message msg-#{id} owner"
    end
    
    if was_sent_to?(current_user)
      if was_read_by?(current_user)
        self.view_class = "message msg-#{id} recieved read"
      else
        self.view_class = "message msg-#{id} recieved unread"
      end
    end
  end

  def mark_read_by(user)
    if self.read_by
      self.read_by.merge!(user.user_name => user.workstation_names_str) unless self.read_by.has_key?(user.user_name)
    else
      self.read_by = { user.user_name => user.workstation_names_str }
    end
    save
  end

  def readers
    readers = ""
    if self.read_by
      users = self.read_by.keys
      workstations = self.read_by.values
      users.each_index do |index|
        if index == (users.size - 1) and users.size > 1
          readers += " and " 
        elsif index > 0
          readers += ", "
        end
        readers += "#{users[index]}@#{workstations[index]}"
      end
      readers += " read this."
    end
    readers
  end

  def was_sent_to?(user)
    sent_to = false
    self.receivers.each do |receiver|
      if receiver.user_id == user.id or (user.workstation_ids.include?(receiver.workstation_id) and receiver.user == nil)
        sent_to = true
        break
      end
    end
    sent_to
  end

  def was_read_by?(user)
    read = false
    if self.read_by
      if read_by.has_key?(user.user_name)
        read = true
      end
    end
    read
  end
end
