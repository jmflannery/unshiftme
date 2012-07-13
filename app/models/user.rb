class User < ActiveRecord::Base
  include SessionsHelper

  has_secure_password 

  attr_accessible :user_name, :password, :password_confirmation 
  
  has_many :messages
  has_many :transcripts
  has_many :recipients
  has_many :attachments
  
  serialize :normal_desks
  
  validates :user_name, presence: true, uniqueness: true
  
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true 

  scope :online, lambda { where("status = true") }

  def self.sign_out_the_dead
    logger.debug "Executing: User#sign_out_the_dead"
    online.each do |user|
      delta = Time.now - user.heartbeat if user.heartbeat
      if delta and delta > 30
        user.set_offline
        logger.debug "User: <#{user.user_name} ##{user.id}> has not had a heartbeat in #{delta} seconds since #{user.heartbeat} and has been set to 'offline'"
      end
    end
    logger.debug "Done executing: User#sign_out_the_dead"
  end

  def handle
    "#{user_name}@#{desk_names_str}"
  end

  def recipient_desk_ids
    ids = []
    recipients.each do |recipient|
      ids << recipient.desk_id
    end
    ids
  end  

  def add_recipients(desks)
    recipients = []
    desks.each do |desk|
      recipient = add_recipient(desk)
      recipients << recipient if recipient
    end
    recipients
  end

  def add_recipient(desk)
    recipient = nil
    unless recipient_desk_ids.include?(desk.id) or desks.include?(desk.id)
      recipient = recipients.create(desk_id: desk.id)
    end
    recipient
  end

  def do_heartbeat
    touch :heartbeat
  end

  def set_heartbeat(time)
    update_attribute(:heartbeat, time)
  end

  def set_online
    update_attribute(:status, true)
    update_attribute(:heartbeat, Time.now)
  end

  def set_offline
    update_attribute(:status, false)
    leave_desk
    delete_all_recipients
  end

  def remove_stale_recipients
    stale_recipients = []
    self.recipients.each do |recipient|
      r_user = User.find_by_id(Desk.find(recipient.desk_id).user_id)
      if r_user.status == false || (r_user.heartbeat < Time.now - 4) 
        stale_recipients << recipient 
        r_user.set_offline
      end
    end
    self.recipients = self.recipients - stale_recipients
    self.save validate: false
  end

  def authenticate_desk(params)
    params.each do |key, val|
      desk = Desk.find_by_abrev(key)
      if desk
        desk.user_id = self.id
        desk.save
      end
    end
    true
  end

  def start_job(job_abrev)
    job = Desk.find_by_abrev(job_abrev)
    job.user_id = self.id
    job.save
  end
   
  def start_jobs(job_abrevs)
    job_abrevs.each do |job_abrev|
      start_job(job_abrev)
    end
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
    desks.each do |desk_id|
      desk = Desk.find(desk_id)
      desk.update_attributes({user_id: 0})
    end
  end

  def messaging?(desk_id)
    recipients.each do |recipient|
      if recipient.desk_id == desk_id
        return true
      end
    end
    false
  end

  def recipient_id(desk_id)
    recipient_id = nil  
    recipients.each do |recipient|
      if recipient.desk_id == desk_id
        recipient_id = recipient.id 
        break
      end
    end
    recipient_id
  end

  def delete_all_recipients
    recipients.each { |recipient| recipient.destroy } 
  end
end
