# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  full_name       :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  status          :boolean
#  recipient_id    :integer
#  lastpoll        :datetime
#

class User < ActiveRecord::Base

  has_secure_password 

  attr_accessible :name, :full_name, :email, :password, :password_confirmation 
  
  has_many :messages
  has_many :recipients
  has_many :attachments

  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

  default_scope :order => 'users.full_name ASC'

  scope :online, lambda { |user_id| where("users.status = ? and users.id != ?", true, user_id) }

  def self.available_users(user)
    available_users = []
    User.online(user.id).each do |online_user|
      available_users << online_user unless user.recipient_user_ids.include?(online_user.id) 
    end
    available_users
  end

  def recipient_user_ids
    ids = []
    recipients.each do |recipient|
      ids << recipient.recipient_user_id
    end
    ids
  end  

  def add_recipients(user_ids)
    user_ids.each do |id|
      unless recipient_user_ids.include?(id)
        recipient_user = User.find(id) 
        recipients.create!(:recipient_user_id => id) if recipient_user
      end
    end
  end

  def timestamp_poll(time)
    self.lastpoll = time
    self.save validate: false
  end

  def set_online
    self.status = true
    self.save validate: false
  end

  def set_offline
    self.status = false
    self.save validate: false
  end

  def remove_stale_recipients
    stale_recipients = []
    self.recipients.each do |recipient|
      r_user = User.find(recipient.recipient_user_id)
      if r_user.status == false || (r_user.lastpoll < Time.now - 4) 
        stale_recipients << recipient 
        r_user.set_offline
      end
    end
    self.recipients = self.recipients - stale_recipients
    self.save validate: false
  end
end
