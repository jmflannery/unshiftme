class Transcript < ActiveRecord::Base

  attr_accessible :transcript_user_id, :start_time, :end_time

  belongs_to :user
  belongs_to :transcript_user, class_name: User
   
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
    user_name = transcript_user ? transcript_user.user_name : ""
    start_str = start_time.strftime("%b %d %Y %H:%M")
    end_str = end_time.strftime("%b %d %Y %H:%M")
    "Transcript for #{user_name} from #{start_str} to #{end_str}"
  end

  def display_messages
    transcript_user.display_messages(start_time: start_time, end_time: end_time)
  end

  def as_json(options = {})
    json = {}
    json[:start_time] = start_time.to_s
    json[:end_time] = end_time.to_s
    json[:user] = transcript_user_id if transcript_user_id
    json[:messages] = display_messages.map { |msg| MessagePresenter.new(msg, options[:user]).as_json(transcript: true) }
    json.as_json
  end
end

