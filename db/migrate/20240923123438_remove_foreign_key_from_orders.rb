class RemoveForeignKeyFromOrders < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :orders, :mpesas
  end
end
