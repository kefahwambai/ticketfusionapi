class OrdersController < InheritedResources::Base
  def create
    @order = Order.new(order_params)

    ActiveRecord::Base.transaction do
      if @order.save
        ticket = Ticket.find(@order.ticket_id)

        quantity_sold = params[:order][:quantity].to_i
        if ticket && ticket.max_quantity && ticket.max_quantity >= quantity_sold
          ticket.update!(max_quantity: ticket.max_quantity - quantity_sold)

          event = ticket.event
          ActionCable.server.broadcast "ticket_sales_#{event.id}_channel", {
            tickets_left: ticket.max_quantity,
            ticket_id: ticket.id
          }

          TicketMailer.ticket_email(@order.email, ticket).deliver_now

          # Initiate MPesa payment
          MpesasController.new.stkpush

          render json: @order, status: :created
        else
          Rails.logger.error "Not enough tickets left"
          render json: { errors: ['Not enough tickets left for this event'] }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Error occurred while processing the order: #{e.message}"
    render json: { errors: ['An error occurred while processing the order'] }, status: :internal_server_error
  end

  private

  def order_params
    params.require(:order).permit(:ticket_id, :sales_id, :phoneNumber, :email, :promo_code, :quantity)
  end
end
