class OrderSerializer < ActiveModel::Serializer
  attributes :id, :phoneNumber, :email
  has_one :ticket
  has_one :sale
end
