class RemoveTotalTicketsFromTickets < ActiveRecord::Migration[7.0]
  def change
    remove_column :tickets, :total_tickets, :string
  end
end
