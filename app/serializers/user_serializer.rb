class UserSerializer < ActiveModel::Serializer
  attributes :id, :user_name
  has_many :workstations
  has_many :message_routes
end
