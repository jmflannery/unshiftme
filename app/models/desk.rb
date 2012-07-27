class Desk < ActiveRecord::Base
  attr_accessible :name, :abrev, :job_type, :user_id

  scope :of_type, lambda { |type| where("job_type = ?", type) }
  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }
  
  default_scope order("id")

  def self.all_short_names
    Desk.all.map { |desk| desk.abrev }
  end

  def description
    desc = name
    desc += " (#{User.find_by_id(user_id).user_name})" if User.exists?(user_id)
    desc
  end
end
