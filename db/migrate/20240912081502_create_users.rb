class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :business_name
      t.integer :phone_number
      t.string :name
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
