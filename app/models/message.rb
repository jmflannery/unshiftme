class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id

  serialize :read_by
  serialize :sent
  serialize :recievers
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 300 }
  validates :user_id, :presence => true

  default_scope order("created_at DESC")

  scope :before, lambda { |time| where("created_at >= ? and created_at <= ?", time - 1.day, time) }
  scope :between, lambda { |timeFrom, timeTo| where("created_at >= ? and created_at <= ?", timeFrom, timeTo) }

  def set_recievers
    user.recipients.each do |recipient|
      desk = Desk.find_by_id(recipient.desk_id)
      recip_user = User.find_by_id(desk.user_id)
      name = recip_user ? recip_user.user_name : ""
      if self.recievers
        self.recievers.merge!(desk.abrev => name) unless self.recievers.has_key?(desk.abrev)
      else
        self.recievers = { desk.abrev => name }
      end
    end
    save
  end

  def set_recieved_by(desk)
    recip_user = User.find_by_id(desk.user_id)
    name = recip_user ? recip_user.user_name : ""
    if self.recievers
      self.recievers.merge!(desk.abrev => name) unless self.recievers.has_key?(desk.abrev)
    else
      self.recievers = { desk.abrev => name }
    end
    save
  end

  def broadcast
    user = User.find(user_id)
    user.recipients.each do |recipient|
      desk = Desk.find(recipient.desk_id)
      set_recieved_by(desk)
      if User.exists?(desk.user_id)
        recip_user = User.find(desk.user_id) 
        user.desks.each { |desk_id| recip_user.add_recipient(Desk.find(desk_id)) }
        
        data = { 
          chat_message: content,
          sender: user.handle,
          from_desks: user.desk_names_str,
          recipient_id: recipient.id,
          timestamp: created_at.strftime("%a %b %e %Y %T"),
          view_class: "message #{id.to_s} recieved unread"
        }
        PrivatePub.publish_to("/messages/#{recip_user.user_name}", data)
      end
    end
  end

  def set_sent_by
    self.sent = [] 
    user.desk_names.each do |desk_abrev|
      self.sent << desk_abrev
    end
    save
  end
  
  def sent_by
    sent_by = ""
    if self.sent
      self.sent.each_index do |index|
        sent_by += "," unless index == 0
        sent_by += self.sent[index]
      end
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
    self.before(time).each do |message|
      if message.was_sent_by?(user)
        message.view_class = "message #{message.id} owner"
        messages << message
        next
      end

      if message.was_sent_to?(user)
        messages << message 

        if message.was_read_by?(user)
          message.view_class = "message #{message.id} recieved read"
        else
          message.view_class = "message #{message.id} recieved unread"
        end
      end
    end
    messages
  end

  def self.for_user_between(user, timeFrom, timeTo)
    messages = []
    self.between(timeFrom, timeTo).each do |message|
      if message.was_sent_by?(user)
        message.view_class = "message #{message.id} owner"
        messages << message
        next
      end
      
      if message.was_sent_to?(user)
        messages << message 

        if message.was_read_by?(user)
          message.view_class = "message #{message.id} recieved read"
        else
          message.view_class = "message #{message.id} recieved unread"
        end
      end
    end
    messages
  end

  def mark_read_by(user)
    if self.read_by
      self.read_by.merge!(user.user_name => user.desk_names_str) unless self.read_by.has_key?(user.user_name)
    else
      self.read_by = { user.user_name => user.desk_names_str }
    end
    save
  end

  def readers
    readers = ""
    if self.read_by
      users = self.read_by.keys
      desks = self.read_by.values
      users.each_index do |index|
        if index == (users.size - 1) and users.size > 1
          readers += " and " 
        elsif index > 0
          readers += ", "
        end
        readers += "#{users[index]}@#{desks[index]}"
      end
      readers += " read this."
    end
    readers
  end

  def was_sent_to?(user)
    sent_to = false
    if self.recievers
      desks = user.desk_names
      self.recievers.each_pair do |desk_abrev, user_name|
        if desks.include?(desk_abrev) or user.user_name == user_name
          sent_to = true 
          break
        end
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
