class Event < ApplicationRecord
  belongs_to :user
  has_many :tickets
  has_many :sales
  mount_uploader :image, ImageUploader

  validates :name, :description, :date, :location, :image, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "date", "description", "id", "image", "location", "name", "updated_at", "user_id"]
  end

  # Define searchable associations
  def self.ransackable_associations(auth_object = nil)
    ["sales", "tickets", "user"]
  end
end
