class AddValidatedAtToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :validated_at, :datetime
  end
end
