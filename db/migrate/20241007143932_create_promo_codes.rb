class CreatePromoCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.decimal :discount
      t.datetime :valid_until
      t.boolean :used

      t.timestamps
    end
  end
end
