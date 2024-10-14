class CreateSales < ActiveRecord::Migration[7.0]
  def change
    create_table :sales do |t|
      t.references :event, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.decimal :revenue

      t.timestamps
    end
  end
end
