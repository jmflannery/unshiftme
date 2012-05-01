class User < ActiveRecord::Base

  has_secure_password 

  attr_accessible :first_name, :middle_initial, :last_name, :user_name, :email, :password, :password_confirmation 
  
  has_many :messages
  has_many :transcripts
  has_many :recipients
  has_many :attachments
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :user_name, presence: true, uniqueness: true
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true 

  default_scope order: 'users.last_name ASC'

  scope :online, lambda { |user_id| where("users.status = ? and users.id != ?", true, user_id) }

  def self.available_users(user)
    available_users = []
    User.online(user.id).each do |online_user|
      available_users << online_user unless user.recipient_user_ids.include?(online_user.id) 
    end
    available_users
  end

  def full_name
    full_name = self.first_name
    full_name += " #{self.middle_initial}." if self.middle_initial 
    full_name += " #{self.last_name}"
    full_name
  end

  def recipient_user_ids
    ids = []
    recipients.each do |recipient|
      ids << recipient.recipient_user_id
    end
    ids
  end  

  def add_recipients(users)
    users.each do |user|
      add_recipient(user)
    end
  end

  def add_recipient(user)
    unless recipient_user_ids.include?(user.id)
      recipients.create!(recipient_user_id: user.id, recipient_desk_id: user.desks) if User.exists?(user.id)
    end
  end
  
  def add_desk_recipient(desk)
    unless desks.include?(desk.id)
      recipients.create!(recipient_user_id: 0, recipient_desk_id: [desk.id])
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

  def authenticate_desk(params)
    params.each do |key, val|
      Desk.all.each do |desk|
        if (desk.abrev == key)
          desk.user_id = self.id
          desk.save
        end
      end
    end
    true
  end

  def desks
    Desk.of_user(self.id).map { |desk| desk.id }
  end

  def leave_desk
    self.desks.each do |desk_id|
      desk = Desk.find(desk_id)
      desk.user_id = 0
      desk.save
    end
  end
end
