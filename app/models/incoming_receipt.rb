class IncomingReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :workstation
  belongs_to :user
  belongs_to :attachment
end

