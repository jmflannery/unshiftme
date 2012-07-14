class Transcript < ActiveRecord::Base

  attr_accessible :transcript_desk_id, :transcript_user_id, :start_time, :end_time

  belongs_to :user
   
  #validates :transcript_user_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  #validate :acceptable_start_date
  #validate :acceptable_end_date
  
  scope :for_user, lambda { |user_id| where("user_id = ?", user_id) }

  def acceptable_start_date
    errors.add("start_time", "is not within acceptable range") unless date_within(self.start_time, 3.days.ago, 2.second.ago)
  end

  def acceptable_end_date
    errors.add("end_time", "is not within acceptable range") unless date_within(self.end_time, 3.days.ago, 2.second.ago)
  end

  def date_within(time, timeFrom, timeTo)
    unless time.nil? or time == 0
      if time >= timeFrom and time <= timeTo
        return true
      else
        return false
      end
    end
  end
end
