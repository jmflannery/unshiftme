class Receiver < ActiveRecord::Base
  attr_accessible :message_id

  belongs_to :message
  belongs_to :workstation
  belongs_to :user
end

