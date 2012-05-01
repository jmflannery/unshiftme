# == Schema Information
#
# Table name: recipients
#
#  id                :integer         not null, primary key
#  user_id           :integer
#  recipient_user_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Recipient < ActiveRecord::Base
  serialize :recipient_desk_id

  belongs_to :user

  attr_accessible :recipient_user_id, :recipient_desk_id
  
  #validates :recipient_user_id, :uniqueness => { :scope => :user_id }

  scope :for_user, lambda { |user_id| where("user_id = ?", user_id) }
end
