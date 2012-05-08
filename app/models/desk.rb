class Desk < ActiveRecord::Base
  attr_accessible :name, :abrev, :job_type, :user_id

  scope :of_type, lambda { |type| where("job_type = ?", type) }
  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }
  
  default_scope order("id")

  def description
    desc = name
    desc += " (#{User.find_by_id(user_id).user_name})" if user_id && user_id > 0
    desc
  end
end
