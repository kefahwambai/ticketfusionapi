class UserSerializer < ActiveModel::Serializer
  attributes :id, :business_name, :name, :email
  has_many :events
end
