require 'httparty'

class CheckPaymentStatusJob < ApplicationJob
  queue_as :default

  def perform(checkout_request_id, phone_number, total_price, ticket_id, quantity)
    begin
      # Poll for M-PESA payment confirmation
      poll_interval = 60.seconds

      loop do
        response = check_mpesa_payment_status(checkout_request_id)

        if response[:status] == 'Success'
          # Process successful payment (create sale, order, etc.)
          process_successful_payment(ticket_id, total_price, phone_number, quantity)
          break
        elsif response[:status] == 'Failed'
          # Handle failed payment
          handle_failed_payment
          break
        end

        # Wait for next polling cycle
        sleep(poll_interval)
      end
    rescue StandardError => e
      # Log error and handle any failure in polling
      logger.error "Error in CheckPaymentStatusJob: #{e.message}"
      handle_failed_payment
    end
  end

  private

  def check_mpesa_payment_status(checkout_request_id)
    # Here, make the request to M-PESA to check payment status
    response = HTTParty.post(
      'http://localhost:3000/stkquery',
      body: { checkoutRequestID: checkout_request_id }
    )

    if response.success?
      JSON.parse(response.body, symbolize_names: true)
    else
      { status: 'Failed' }
    end
  end

  def process_successful_payment(ticket_id, total_price, phone_number, quantity)
    # Logic to handle successful payment, like creating sale and order
    sale = Sale.create!(ticket_id: ticket_id, revenue: total_price)

    order = Order.create!(
      ticket_id: ticket_id,
      sale_id: sale.id,
      phone_number: phone_number,
      quantity: quantity
    )

    # Optional: Send a confirmation email or notification to the user
    NotificationService.send_payment_confirmation(order)
  end

  def handle_failed_payment
    # Logic to handle failed payment (e.g., notify user or retry)
    logger.error "Payment failed or error occurred while polling."
  end
end
