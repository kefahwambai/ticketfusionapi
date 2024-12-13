class User < ApplicationRecord
  has_many :events
  has_secure_password

  validates :email, presence: true, uniqueness: true, 
    format: { with: /\A[\w+\-.]+@(gmail|yahoo)\.com\z/i, message: "must be a valid Gmail or Yahoo address" }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "business_name", "email", "created_at", "updated_at", "phone_number"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["events"]
  end
end
