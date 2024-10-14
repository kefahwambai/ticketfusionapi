class Order < ApplicationRecord
  belongs_to :ticket
  belongs_to :sale, class_name: 'Sale', foreign_key: 'sales_id' 

  validates :ticket_id, presence: true
  validates :sales_id, presence: true 
  validates :phoneNumber, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :apply_promo_code

  def apply_promo_code
    if promo_code.present?
      code = PromoCode.find_by(code: promo_code)
      if code&.valid_promo
        self.total_price = ticket.price - (ticket.price * (code.discount / 100))
        code.update(used: true)
      end
    end
  end
end
