class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.bigint :event_id
      t.decimal :price
      t.string :ticket_type
      t.string :total_tickets
      t.string :name
      t.time :start_time
      t.time :end_time
      t.integer :max_quantity
      t.integer :group_size
      t.boolean :is_group_ticket
      t.string :qr_code_data
      t.boolean :used

      t.timestamps
    end
  end
end
