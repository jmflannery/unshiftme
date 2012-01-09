# == Schema Information
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  reciever   :integer
#  read       :integer
#  time_read  :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  
  default_scope :order => 'messages.created_at ASC'

  #scope :new_for, lambda { |user_id| where("? not in recievers", user_id) }

  def set_recievers
    user = self.user
    recipients = user.recipients
    count = 0
    recipient_user_ids = ""
    recipients.each do |recipient|
      recipient_user_ids << "," unless count == 0
      recipient_user_ids << recipient.recipient_user_id.to_s
      count += 1
    end
    self.recievers = recipient_user_ids
    self.save
  end

  def mark_sent_to(user)
    if self.sent.blank?
      self.sent = user.id.to_s
    else
      self.sent << "," + user.id.to_s unless sent.include?(user.id.to_s)
    end
    self.save
  end

  def self.new_messages_for(user)
    unsent_messages = []
    messages = Message.all
    messages.each do |message|
      unless message.sent.blank?
        sent_user_ids = message.sent.split(/,/) 
        unsent_messages << message unless sent_user_ids.include?(user.id.to_s)
      else
        unsent_messages << message
      end
    end
    unsent_messages
  end
end
