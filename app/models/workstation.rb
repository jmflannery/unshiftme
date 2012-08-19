class Workstation < ActiveRecord::Base
  attr_accessible :name, :abrev, :job_type, :user_id

  belongs_to :user

  scope :of_type, lambda { |type| where("job_type = ?", type) }
  scope :of_user, lambda { |user_id| where("user_id = ?", user_id) }
  
  default_scope order("id")

  def set_user(user)
    self.user = user
    save
  end

  def self.as_json
    array = []
    all.each do |workstation|
      hash = {}
      hash[:id] = workstation.id
      hash[:long_name] = workstation.name
      hash[:name] = workstation.abrev
      if User.exists?(workstation.user_id)
        user = User.find(workstation.user_id)
        hash[:user_id] = user.id
        hash[:user_name] = user.user_name
      end
      array << hash
    end
    array.to_json
  end

  def self.all_short_names
    Workstation.all.map { |workstation| workstation.abrev }
  end

  def description
    desc = name
    desc += " (#{User.find_by_id(user_id).user_name}" if User.exists?(user_id)
    desc
  end

  def view_class(user)
    view_class = "recipient_workstation"
    if user.workstation_ids.include?(id)
      view_class += " mine"
    elsif user.messaging?(id)
      view_class += " on #{user.recipient_id(id)}"
    else
      view_class += " off"
    end
    view_class
  end
end

