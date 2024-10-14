class User < ApplicationRecord
  has_many :events
  has_secure_password

  validates :email, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "business_name", "email", "created_at", "updated_at", "phone_number"]
  end

  # Define searchable associations
  def self.ransackable_associations(auth_object = nil)
    ["events"]
  end
end
