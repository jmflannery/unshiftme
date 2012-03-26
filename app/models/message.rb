class Message < ActiveRecord::Base
  attr_accessible :content, :attachment_id
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

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
        messages << message
        next
      end

      if message.recievers
        recievers = message.recievers.split(",")
        messages << message if recievers.include?(user.id.to_s)
      end
    end
    messages
  end
end
