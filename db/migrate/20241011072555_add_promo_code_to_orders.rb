class AddPromoCodeToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :promo_code, :string
  end
end
