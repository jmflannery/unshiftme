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
#

class User < ActiveRecord::Base

  has_secure_password 

  attr_accessible :name, :full_name, :email, :password, :password_confirmation 
  
  has_many :messages
  
  has_many :recipients

  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

  default_scope :order => 'users.full_name ASC'

  scope :online, lambda { |user_id| where("users.status = ? and users.id != ?", true, user_id) }

  def self.available_users(user)
    recipient_ids = Recipient.my_recipient_user_ids(user.id)
    users = User.online(user.id) 
    available_users = []
    users.each do |user|
      available_users << user unless recipient_ids.include?(user.id) 
    end
    available_users
  end

  def recipient_user_ids
    ids = []
    self.recipients.each do |recipient|
      ids << recipient.recipient_user_id
    end
    ids
  end  

  def add_recipients(user_ids)
    user_recipients = self.recipient_user_ids
    user_ids.each do |id|
      self.recipients.create!(:recipient_user_id => id) unless user_recipients.include?(id)
    end
  end
end

