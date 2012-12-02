class User < ActiveRecord::Base
  include SessionsHelper

  has_secure_password 

  attr_accessible :user_name, :password, :password_confirmation, :normal_workstations, :admin
 
  has_many :workstations
  has_many :messages
  has_many :recipients
  has_many :transcripts
  has_many :attachments
  
  serialize :normal_workstations
  
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :user_name, presence: true, uniqueness: true
  validates :password, presence: true, length: { within: 6..40 }, if: :should_validate_password?
  validates :password_confirmation, presence: true, if: :should_validate_password?

  IDLE_TIME = 15

  after_create :init_admin

  def init_admin
    update_attribute(:admin, User.count == 1)
  end

  def to_param
    user_name
  end

  def should_validate_password?
    new_record? || updating_password?
  end

  def updating_password!
    @updating_password = true
  end

  def updating_password?
    @updating_password
  end

  def self.online
    time_limit = Time.zone.now - IDLE_TIME.seconds
    User.where("heartbeat >= ?", time_limit)
  end

  def self.all_user_names
    User.all.map { |user| user.user_name } 
  end

  def as_json
    json = {}
    json[:id] = id
    json[:user_name] = user_name
    json[:workstations] = workstation_names.map { |name| {name: name} }
    json[:recipient_workstations] = recipients.map do |recipient|
      { name: Workstation.find(recipient.workstation_id).abrev, recipient_id: recipient.id }
    end
    json.to_json
  end

  def handle
    "#{user_name}@#{workstation_names_str}"
  end

  def recipient_workstation_ids
    recipients.map { |recipient| recipient.workstation_id }
  end  

  def add_recipients(workstations)
    recipients = []
    workstations.each do |workstation|
      recipient = add_recipient(workstation)
      recipients << recipient if recipient
    end
    recipients
  end

  def add_recipient(workstation)
    recipient = nil
    unless recipient_workstation_ids.include?(workstation.id) or workstation_ids.include?(workstation.id)
      recipient = recipients.create(workstation_id: workstation.id)
    end
    recipient
  end

  def do_heartbeat(time)
    update_attribute(:heartbeat, time)
  end

  def set_online
    do_heartbeat(Time.now)
  end

  def set_offline
    leave_workstation
    delete_all_recipients
  end

  def remove_stale_recipients
    stale_recipients = []
    self.recipients.each do |recipient|
      r_user = User.find_by_id(Workstation.find(recipient.workstation_id).user_id)
      if r_user.heartbeat < Time.now - IDLE_TIME
        stale_recipients << recipient 
        r_user.set_offline
      end
    end
    self.recipients = self.recipients - stale_recipients
    self.save validate: false
  end

  def start_job(abrev)
    workstation = Workstation.find_by_abrev(abrev)
    workstation.set_user(self) if workstation
  end
   
  def start_jobs(abrevs)
    abrevs.each do |abrev|
      start_job(abrev)
    end
  end

  def workstation_names
    self.workstations.map { |workstation| workstation.abrev }
  end

  def workstation_ids
    self.workstations.map { |workstation| workstation.id }
  end

  def workstation_names_str
    workstations = ""
    workstation_names.each_with_index do |workstation_name, i|
      workstations += "," unless i == 0
      workstations += workstation_name
    end
    workstations
  end

  def leave_workstation
    workstations.each do |workstation|
      workstation.user_id = 0
      workstation.save
    end
    save
  end

  def messaging?(workstation_id)
    recipients.each do |recipient|
      if recipient.workstation_id == workstation_id
        return true
      end
    end
    false
  end

  def recipient_id(workstation_id)
    recipient_id = nil  
    recipients.each do |recipient|
      if recipient.workstation_id == workstation_id
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

