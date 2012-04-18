class Message < ActiveRecord::Base
  attr_accessor :view_class

  attr_accessible :content, :attachment_id
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope order("created_at DESC")

  scope :before, lambda { |time| where("created_at <= ? and created_at >= ?", time, time - 1.day) }

  def set_recievers
    first = true
    recipient_user_ids = ""
    user.recipients.each do |recipient|
      recipient_user_ids << "," unless first
      recipient_user_ids << recipient.recipient_user_id.to_s
      first = false
    end
    self.recievers = recipient_user_ids
    save
  end

  def self.before_for(user, time)
    messages = []
    self.before(time).each do |message|
      if message.user_id == user.id
        message.view_class = "message #{message.id} owner"
        messages << message
        next
      end

      if message.recievers
        recievers = message.recievers.split(",")

        if recievers.include?(user.id.to_s)
          messages << message

          if message.read_by
            if message.read_by.split(",").include?(user.id.to_s)
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
    if self.read_by
      self.read_by += ",#{user.id.to_s}" unless self.read_by.split(",").include?(user.id.to_s)
    else
      self.read_by = user.id.to_s
    end
    save
  end

  def readers
    readers = ""
    if self.read_by
      readit = self.read_by.split(",")
      readit.each_with_index do |user_id, i|
        if i == (readit.size - 1) and readit.size > 1
          readers += " and " 
        elsif i > 0
          readers += ", "
        end
        readers += User.find(user_id).name
      end
      readers += " read this."
    end
    readers
  end
end
