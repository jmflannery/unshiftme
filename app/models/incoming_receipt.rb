class IncomingReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :workstation
  belongs_to :user
end

