class OutgoingReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :user
  
 serialize :workstations
end

