class Desk < ActiveRecord::Base
  attr_accessible :name, :abrev, :job_type

  scope :of_type, lambda { |type| where("job_type = ?", type) }
end
