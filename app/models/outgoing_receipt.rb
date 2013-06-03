class OutgoingReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :user
  belongs_to :attachment
  
  serialize :workstations
end

