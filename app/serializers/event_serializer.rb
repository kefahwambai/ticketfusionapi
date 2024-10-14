class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date, :location, :image
  # belongs_to :user
  has_many :tickets
end
