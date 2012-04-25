class Transcript < ActiveRecord::Base

  attr_accessible :watch_user_id, :start_time, :end_time

  belongs_to :user
   
  validates :watch_user_id, presence: true
  validates :start_time, presence: true, inclusion: 1.day.ago..1.second.ago
  validates :end_time, presence: true
  validate :acceptable_start_date
  validate :acceptable_end_date

  def acceptable_start_date
    errors.add("start_date", "is not within acceptable range") unless date_within(self.start_time, 3.days.ago, 1.second.ago)
  end

  def acceptable_end_date
    errors.add("end_date", "is not within acceptable range") unless date_within(self.start_time, 3.days.ago, 1.second.ago)
  end

  def date_within(time, timeFrom, timeTo)
    if time >= timeFrom and time <= timeTo
      return true
    else
      return false
    end
  end
end
