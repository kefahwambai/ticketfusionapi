class TicketSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :price, :ticket_type, :name, :start_time, :end_time, :max_quantity, :group_size, :is_group_ticket, :qr_code_data, :used, :total_tickets  
  belongs_to :event
end
