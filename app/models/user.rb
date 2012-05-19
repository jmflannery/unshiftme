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
  scope :online, lambda { where("status = true") }

  def full_name
    full_name = self.first_name
    full_name += " #{self.middle_initial}." unless self.middle_initial.blank?
    full_name += " #{self.last_name}"
    full_name
  end

  def recipient_desk_ids
    ids = []
    recipients.each do |recipient|
      ids << recipient.desk_id
    end
    ids
  end  

  def add_recipients(desks)
    desks.each do |desk|
      add_recipient(desk)
    end
  end

  def add_recipient(desk)
    recipient = nil
    unless recipient_desk_ids.include?(desk.id)
      recipient = recipients.create(desk_id: desk.id)
    end
    recipient
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
      r_user = User.find_by_id(Desk.find(recipient.desk_id).user_id)
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
    Desk.of_user(self.id).collect { |desk| desk.id }
  end

  def desk_names
    Desk.of_user(self.id).collect { |desk| desk.abrev }
  end

  def desk_names_str
    desks = ""
    desk_names.each_with_index do |desk_name, i|
      desks += "," unless i == 0
      desks += desk_name
    end
    desks
  end

  def leave_desk
    self.desks.each do |desk_id|
      desk = Desk.find(desk_id)
      desk.user_id = 0
      desk.save
    end
  end

  def messaging?(desk_id)
    recipient_id = nil  
    recipients.each do |recipient|
      if recipient.desk_id == desk_id
        recipient_id = recipient.id 
        break
      end
    end
    recipient_id
  end
end
