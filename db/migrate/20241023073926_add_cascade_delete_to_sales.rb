class AddCascadeDeleteToSales < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :sales, :events
    add_foreign_key :sales, :events, on_delete: :cascade
  end
end
