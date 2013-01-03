class Transcript < ActiveRecord::Base

  attr_accessible :transcript_workstation_id, :transcript_user_id, :start_time, :end_time

  belongs_to :user
  belongs_to :transcript_user, class_name: User
  belongs_to :transcript_workstation, class_name: Workstation
   
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
    workstation_abrev = transcript_workstation ? transcript_workstation.abrev : ""
    user_name = transcript_user ? transcript_user.user_name : ""
    user_workstation = workstation_abrev
    user_workstation += " " unless user_name.blank? or workstation_abrev.blank?
    user_workstation += user_name
    start_str = start_time.strftime("%b %d %Y %H:%M")
    end_str = end_time.strftime("%b %d %Y %H:%M")
    "Transcript for #{user_workstation} from #{start_str} to #{end_str}"
  end

  def display_messages
    transcript_user.display_messages(start_time: start_time, end_time: end_time)
  end

  def to_json
    json = {}
    json[:start_time] = start_time.to_s
    json[:end_time] = end_time.to_s
    json[:user] = transcript_user_id if transcript_user_id
    json[:workstation] = transcript_workstation_id if transcript_workstation_id
    json.as_json
  end
end
