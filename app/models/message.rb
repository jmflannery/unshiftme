# == Schema Information
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  read       :integer
#  time_read  :datetime
#  created_at :datetime
#  updated_at :datetime
#  recievers  :string(255)
#  sent       :string(255)
#

class Message < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  
  default_scope :order => 'messages.created_at ASC'

  scope :since, lambda { |time| where("created_at >= ?", time) } 

  ## TODO: Fix me! I'm broken!
  scope :messages_for, lambda { |user_id| where("recievers like '%#{user_id}%' or user_id = ?", user_id) }

  def set_recievers
    recipients = self.user.recipients
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
      #self.sent << "," + user.id.to_s unless sent.include?(user.id.to_s)
      self.sent = self.sent + "," + user.id.to_s
    end

    self.save 
  end

  def self.new_messages_for(user)
    unsent_messages = []
    messages = messages_for(user.id)
    messages.each do |message|
      delivered_to_user_ids = []
      delivered_to_user_ids = message.sent.split(/,/) unless message.sent.blank?
      unsent_messages << message unless delivered_to_user_ids.include?(user.id.to_s)
    end
    unsent_messages
  end
end
