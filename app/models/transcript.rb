class Transcript < ActiveRecord::Base

  attr_accessible :transcript_desk_id, :transcript_user_id, :start_time, :end_time

  belongs_to :user
   
  #validates :transcript_user_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  #validate :acceptable_start_date
  #validate :acceptable_end_date
  
 default_scope order: 'created_at DESC'
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

  def name
    desk_abrev = Desk.exists?(transcript_desk_id) ? Desk.find(transcript_desk_id).abrev : ""
    user_name = User.exists?(transcript_user_id) ? User.find(transcript_user_id).user_name : ""
    user_desk = desk_abrev
    user_desk += " " unless user_name.blank? or desk_abrev.blank?
    user_desk += user_name
    start_str = start_time.strftime("%b %d %Y %H:%M")
    end_str = end_time.strftime("%b %d %Y %H:%M")
    "Transcript for #{user_desk} from #{start_str} to #{end_str}"
  end
end
