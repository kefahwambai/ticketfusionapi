class AddFieldToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :mpesas, null: false, foreign_key: true
  end
end
