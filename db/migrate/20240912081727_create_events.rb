class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :date
      t.string :location
      t.time :start_time
      t.string :image
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
