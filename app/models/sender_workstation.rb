class SenderWorkstation < ActiveRecord::Base
  attr_accessible :message_id

  belongs_to :message
  belongs_to :workstation
end
