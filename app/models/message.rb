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
    recievers_list = []
    user.recipients.each do |recipient|
      desk = Desk.find_by_id(recipient.desk_id)
      recip_user = User.find_by_id(desk.user_id)
      node = { desk_id: desk.id }
      node = node.merge({ user_id: recip_user.id }) if recip_user
      recievers_list << node
    end
    self.recievers = recievers_list
    save
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
    hash = Hash.new
    hash[:user] = user.id.to_s
    hash[:desks] = user.desk_names_str
    if self.read_by
      self.read_by << hash
    else
      reads = Array.new
      reads << hash
      self.read_by = reads
    end
    save
  end

  def readers
    readers = ""
    if self.read_by
      readit = self.read_by
      readit.each_index do |index|
        if index == (readit.size - 1) and readit.size > 1
          readers += " and " 
        elsif index > 0
          readers += ", "
        end
        user = User.find(readit[index][:user].to_i)
        readers += "#{user.desk_names_str} (#{user.user_name})"
      end
      readers += " read this."
    end
    readers
  end

  def was_sent_to?(user)
    if self.recievers
      msg_user = User.find(self.user_id)
      self.recievers.each do |reciever|
        if user.id == reciever[:user_id] or (msg_user.desks.include?(reciever[:desk_id]) and !reciever[:user_id])
          return true 
        end
      end
    end
    false
  end

  def was_read_by?(user)
    if self.read_by
      self.read_by.each do |read_by|
        if read_by[:user] == user.id.to_s
          return true
        end
      end
    end
    false
  end
end
