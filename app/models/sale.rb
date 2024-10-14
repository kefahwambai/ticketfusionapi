class Sale < ApplicationRecord
  belongs_to :event
  belongs_to :ticket
  has_many :orders

  validates :revenue, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "revenue", "ticket_id", "event_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["ticket", "event"]
  end
end
