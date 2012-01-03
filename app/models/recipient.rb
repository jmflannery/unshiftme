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

  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }

  def self.my_recipients(user_id)
    user_recipients = of_user(user_id)
    recipients_list = []
    recips = []
    counter = 0
    user_recipients.each do |r|
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
end
