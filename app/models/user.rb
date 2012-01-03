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

  #scope :online, where("users.status = ?", true)
  scope :online, lambda { |user_id| where("users.status = ? and users.id != ?", true, user_id) }

  #before_save :encrypt_password

  #def self.authenticate(name, submitted_password)
  #  user = find_by_name(name)
  #  return nil if user.nil?
  #  return user if user.has_password?(submitted_password)
  #end

  #def self.authenticate_with_salt(id, cookie_salt)
  #  user = find_by_id(id)
  #  (user && user.salt == cookie_salt) ? user : nil
  #end

  #def has_password?(submitted_password)
  #  encrypted_password == encrypt(submitted_password)
  #end

  private

    #def encrypt_password
    #  self.salt = make_salt if new_record?
    #  self.encrypted_password = encrypt(password)
    #end

    #def encrypt(string)
    #  secure_hash("#{salt}--#{string}")
    #end

    #def make_salt
    #  secure_hash("#{Time.now.utc}--#{password}")
    #end

    #def secure_hash(string)
    #  Digest::SHA2.hexdigest(string)
    #end

end

