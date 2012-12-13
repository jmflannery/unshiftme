class User < ActiveRecord::Base
  include SessionsHelper

  has_secure_password 

  attr_accessible :user_name, :password, :password_confirmation, :normal_workstations, :admin
 
  has_many :workstations
  has_many :messages
  has_many :transcripts
  has_many :attachments
  has_many :message_routes
  has_many :recipients, :through => :message_routes, :source => :workstation
  has_many :incoming_receipts
  has_many :incoming_messages, :through => :incoming_receipts, :source => :message
  has_many :outgoing_receipts
  has_many :outgoing_messages, :through => :outgoing_receipts, :source => :message
  has_many :acknowledgements
  has_many :read_messages, :through => :acknowledgements, :source => :message
  
  serialize :normal_workstations
  
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :user_name, presence: true, uniqueness: true
  validates :password, presence: true, length: { within: 6..40 }, if: :should_validate_password?
  validates :password_confirmation, presence: true, if: :should_validate_password?

  IDLE_TIME = 15
  MESSAGE_HISTORY_LENGTH = 24.hours.ago 

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
    json[:recipient_workstations] = message_routes.map do |route|
      { name: Workstation.find(route.workstation_id).abrev, recipient_id: route.id }
    end
    json.to_json
  end

  def handle
    "#{user_name}@#{workstation_names_str}"
  end

  def display_messages(options = {})
    start_time = options.fetch(:start_time, MESSAGE_HISTORY_LENGTH)
    end_time = options.fetch(:end_time, Time.now)
    where_clause = "messages.created_at >= ? and messages.created_at <= ?"
    (messages.where(where_clause, start_time, end_time) |
      incoming_messages.where(where_clause, start_time, end_time) |
      unreceived_workstation_messages(start_time: start_time, end_time: end_time)).sort.reverse
  end

  def unreceived_workstation_messages(options = {})
    start_time = options.fetch(:start_time, MESSAGE_HISTORY_LENGTH)
    end_time = options.fetch(:end_time, Time.now)
    where_clause = "messages.created_at >= ? and messages.created_at <= ?"
    workstations.inject([]) do |result, workstation|
      result | workstation.unreceived_messages.where(where_clause, start_time, end_time)
    end
  end

  def recipient_workstation_ids
    recipients.map { |recipient| recipient.id }
  end  

  def add_recipients(workstations)
    new_routes = []
    workstations.each do |workstation|
      message_route = add_recipient(workstation)
      new_routes << message_route if message_route
    end
    new_routes
  end

  def add_recipient(workstation)
    message_route = nil
    unless recipients.include?(workstation) or workstations.include?(workstation)
      message_route = message_routes.create(workstation: workstation)
      save
    end
    message_route
  end

  def do_heartbeat(time)
    update_attribute(:heartbeat, time)
  end

  def set_online
    do_heartbeat(Time.now)
  end

  def set_offline
    leave_workstation
    delete_all_message_routes
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

  def messaging?(workstation)
    recipients.each do |recipient|
      if recipient.id == workstation.id
        return true
      end
    end
    false
  end

  def message_route_id(workstation)
    route_id = 0
    message_routes.each do |message_route|
      if message_route.workstation_id == workstation.id
        route_id = message_route.id 
        break
      end
    end
    route_id
  end

  def delete_all_message_routes
    message_routes.each { |message_route| message_route.destroy } 
  end
end

