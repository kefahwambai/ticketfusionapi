class Ticket < ApplicationRecord
  belongs_to :event
  has_one :sale

  validates :price, :ticket_type, :name, presence: true

  after_create :generate_qr_code

  def self.ransackable_attributes(auth_object = nil)
    ["id", "price", "ticket_type", "name", "start_time", "end_time", "max_quantity", "group_size", "is_group_ticket", "qr_code_data", "used", "created_at", "updated_at", "total_tickets"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["event", "sale"]
  end

  private

  def generate_qr_code
    self.update_column(:qr_code_data, SecureRandom.uuid)
  end
  
end
