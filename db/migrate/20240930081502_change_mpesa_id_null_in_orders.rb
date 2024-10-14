class ChangeMpesaIdNullInOrders < ActiveRecord::Migration[6.1]
  def change
    change_column :orders, :mpesas_id, :bigint, null: true
  end
end
