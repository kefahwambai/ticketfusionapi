class SaleSerializer < ActiveModel::Serializer
  attributes :id, :revenue
  has_one :event
  has_one :ticket
end
