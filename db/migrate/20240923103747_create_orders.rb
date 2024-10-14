class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :sales, null: false, foreign_key: true
      t.integer :phoneNumber
      t.string :email

      t.timestamps
    end
  end
end
