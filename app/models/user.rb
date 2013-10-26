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
  MESSAGE_RETAIN_PERIOD = 24.hours.ago 

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

  def handle
    "#{user_name}@#{workstation_names_str}"
  end

  def display_messages(options = {})
    start_time = options.fetch(:start_time, MESSAGE_RETAIN_PERIOD)
    end_time = options.fetch(:end_time, Time.now)
    received = incoming_messages.where(created_at: start_time..end_time)
    sent = outgoing_messages.where(created_at: start_time..end_time)
    unreceived = unreceived_workstation_messages(start_time: start_time, end_time: end_time)
    (received | sent | unreceived).sort.reverse
  end

  def unreceived_workstation_messages(options = {})
    start_time = options.fetch(:start_time, MESSAGE_RETAIN_PERIOD)
    end_time = options.fetch(:end_time, Time.now)
    workstations.inject([]) do |results, workstation|
      results | workstation.incoming_messages.
        where("incoming_receipts.user_id is null").
        where("messages.created_at >= ? and messages.created_at <= ?", start_time, end_time)
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

  def create_attached_message(attachment)
    message = nil
    attachment = attachments.build(attachment)
    if attachment.save
      message = messages.create(content: attachment.payload_identifier)
      message.attach(attachment)
    end
    message
  end

  def do_heartbeat(time)
    update_attribute(:heartbeat, time)
  end

  def set_online
    do_heartbeat(Time.zone.now)
  end

  def set_offline
    leave_workstation
    delete_all_message_routes
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

