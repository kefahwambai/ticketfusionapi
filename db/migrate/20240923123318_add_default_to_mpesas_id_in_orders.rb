class AddDefaultToMpesasIdInOrders < ActiveRecord::Migration[6.1]
  def change
    change_column_default :orders, :mpesas_id, 0
  end
end
