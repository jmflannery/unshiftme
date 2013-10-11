class WorkstationSerializer < ActiveModel::Serializer
  attributes :id, :abrev, :name, :user

  def user
    if object.user_id && object.user_id > 0
      User.find_by_id(object.user_id).user_name
    else
      "vacant"
    end
  end
end
