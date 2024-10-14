class AddTotalTicketsToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :total_tickets, :integer
  end
end
