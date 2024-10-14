ActiveAdmin.register Sale do
  permit_params :event_id, :ticket_id, :revenue

  form do |f|
    f.inputs do
      f.input :event
      f.input :ticket
      f.input :revenue
    end
    f.actions
  end

  filter :revenue
  filter :ticket
  filter :event
  filter :created_at
end
