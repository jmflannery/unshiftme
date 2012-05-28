class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id

  serialize :read_by
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
    self.sent = user.desk_names
    save
  end

  def self.for_user_before(user, time)
    messages = []
    self.before(time).each do |message|
      if message.user_id == user.id
        message.view_class = "message #{message.id} owner"
        messages << message
        next
      end

      msg_user = User.find_by_id(message.user_id)
      if message.recievers
        message.recievers.each do |reciever|
          if user.id == reciever[:user_id] or (msg_user.desks.include?(reciever[:desk_id]) and !reciever[:user_id])
            messages << message 
          end

          if message.read_by
            if message.read_by.include?({ user: user.id.to_s, desks: user.desk_names_str })
              message.view_class = "message #{message.id} recieved read"
            else
              message.view_class = "message #{message.id} recieved unread"
            end
          else
            message.view_class = "message #{message.id} recieved unread"
          end
        end
      end
    end
    messages
  end

  def self.for_user_between(user, timeFrom, timeTo)
    messages = []
    self.between(timeFrom, timeTo).each do |message|
      if message.user_id == user.id
        message.view_class = "message #{message.id} owner"
        messages << message
        next
      end

      msg_user = User.find_by_id(message.user_id)
      if message.recievers
        message.recievers.each do |reciever|
          if user.id == reciever[:user_id] or (msg_user.desks.include?(reciever[:desk_id]) and !reciever[:user_id])
            messages << message 
          end

          if message.read_by
            if message.read_by.include?({ user: user.id.to_s, desks: user.desk_names_str })
              message.view_class = "message #{message.id} recieved read"
            else
              message.view_class = "message #{message.id} recieved unread"
            end
          else
            message.view_class = "message #{message.id} recieved unread"
          end
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
end
