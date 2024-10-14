ActiveAdmin.register Ticket do
  permit_params :event_id, :price, :ticket_type, :total_tickets, :name, :start_time, :end_time, :max_quantity, :group_size, :is_group_ticket, :qr_code_data, :used

  form do |f|
    f.inputs do
      f.input :event
      f.input :price
      f.input :ticket_type
      f.input :total_tickets
      f.input :name
      f.input :start_time, as: :time_select
      f.input :end_time, as: :time_select
      f.input :max_quantity
      f.input :group_size
      f.input :is_group_ticket
      f.input :qr_code_data
      f.input :used
    end
    f.actions
  end
end
