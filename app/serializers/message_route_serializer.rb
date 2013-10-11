class MessageRouteSerializer < ActiveModel::Serializer
  attributes :id
  has_one :workstation
end
