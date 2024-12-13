class AddIdentifierToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :identifier, :uuid, default: "gen_random_uuid()", null: false
    add_index :tickets, :identifier, unique: true
  end
end
