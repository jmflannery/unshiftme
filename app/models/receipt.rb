class Receipt < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  serialize :workstation_ids
end

