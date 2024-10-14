class PromoCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :discount, presence: true
  validate :valid_promo
  validates :valid_promo, inclusion: { in: [true, false] }

  def valid_promo
    errors.add(:valid_until, "Promo code expired") if valid_until < Time.current
    errors.add(:used, "Promo code already used") if used
  end
end
