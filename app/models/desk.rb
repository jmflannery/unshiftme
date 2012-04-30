class Desk < ActiveRecord::Base
  attr_accessible :name, :abrev, :job_type

  scope :of_type, lambda { |type| where("job_type = ?", type) }
  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }
end
