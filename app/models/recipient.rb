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
  belongs_to :user
  
  #validates :recipient_user_id, :uniqueness => { :scope => :user_id }

  scope :for_user, lambda { |user_id| where("user_id = ?", user_id) }

  def self.recipients_for(user_id)
    recipients_list = []
    recips = []
    counter = 0
    for_user(user_id).each do |r|
      if counter % 8 == 0 then
        recips = []
        recips << r
        recipients_list << recips
      else
        recips << r
      end
      counter += 1
    end
    recipients_list
  end

  def self.recipient_user_ids_for(user_id)
    recipient_user_ids = []
    for_user(user_id).each do |recipient|
      recipient_user_ids << recipient.recipient_user_id
    end
    recipient_user_ids
  end
end
