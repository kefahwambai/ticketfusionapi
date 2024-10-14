class TicketSalesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ticket_sales_#{params[:event_id]}_channel"
  end
end

