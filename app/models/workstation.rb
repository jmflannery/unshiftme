class Workstation < ActiveRecord::Base
  belongs_to :user
  has_many :message_routes
  has_many :senders, :through => :message_routes, :source => :user
  has_many :incoming_receipts
  has_many :incoming_messages, :through => :incoming_receipts, :source => :message

  scope :of_type, lambda { |type| where("job_type = ?", type) }
  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }

  scope :ordered, -> { order("id ASC") }
  
  def set_user(user)
    self.user = user
    save
  end

  def self.all_short_names
    Workstation.all.map { |workstation| workstation.abrev }
  end

  def description
    desc = name
    desc += " (#{User.find_by_id(user_id).user_name})" if User.exists?(user_id)
    desc
  end

  def user_name
    User.exists?(user_id) ? User.find(user_id).user_name : ""
  end

  def view_class(user)
    view_class = "recipient_workstation"
    if user.workstation_ids.include?(id)
      view_class += " mine"
    elsif user.messaging?(self)
      view_class += " other on #{user.message_route_id(self)}"
    else
      view_class += " other off"
    end
    view_class
  end
end

