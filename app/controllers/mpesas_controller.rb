class MpesasController < ApplicationController
  require 'rest-client'

  # Event Subscription
  def initialize
    super
    ActiveSupport::Notifications.subscribe('order.created') do |name, start, finish, id, payload|
      order = payload[:order]
      update_customer_phonenumber(order.customer_phonenumber)
    end
  end

  # Callback method to process the Mpesa callback data
  def callback
    request_body = request.body.read
    if request_body.present?
      process_callback(request_body)
      render json: { status: 'success' }
    else
      Rails.logger.error "Empty callback request body"
      render json: { error: 'Empty callback data' }, status: :bad_request
    end
  end

  # STK Push method to initiate a transaction
  def stkpush
    phoneNumber = params[:phoneNumber]
    amount = params[:amount]

    unless validate_phone_number(phoneNumber)
      render json: { error: 'Invalid phone number format' }, status: :bad_request
      return
    end

    url = "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    timestamp = Time.now.strftime "%Y%m%d%H%M%S"
    business_short_code = ENV["MPESA_SHORT_CODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")

    payload = {
      'BusinessShortCode': business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': "CustomerPayBillOnline",
      'Amount': amount,
      'PartyA': phoneNumber,
      'PartyB': business_short_code,
      'PhoneNumber': phoneNumber,
      'CallBackURL': "#{ENV["CALLBACK_URL"].strip}/callback",
      'AccountReference': 'TicketFusion',
      'TransactionDesc': "Purchase of Ticket"
    }.to_json

    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }

    begin
      response = RestClient::Request.execute(method: :post, url: url, payload: payload, headers: headers)
      Rails.logger.debug "STK Push Response: #{response.body}"

      mpesa_response = JSON.parse(response.body)
      checkout_request_id = mpesa_response["CheckoutRequestID"]

      ticket_id = params[:ticket_id]
      total_price = params[:amount]
      quantity = params[:quantity]

      CheckPaymentStatusJob.perform_later(checkout_request_id, phoneNumber, total_price, ticket_id, quantity)

      render json: { message: "STK Push initiated successfully", checkoutRequestID: checkout_request_id }, status: :ok
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "STK Push Request failed: #{e.response}"
      render json: { error: "STK Push request failed", details: e.response }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      render json: { error: "An unexpected error occurred" }, status: :internal_server_error
    end
  end

  # STK Query method to check the status of the transaction
  def stkquery
    url = "https://api.safaricom.co.ke/mpesa/stkpushquery/v1/query"
    timestamp = Time.now.strftime "%Y%m%d%H%M%S"
    business_short_code = ENV["MPESA_SHORT_CODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
  
    payload = {
      'BusinessShortCode': business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'CheckoutRequestID': params[:checkoutRequestID]
    }.to_json
  
    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }
  
    begin
      response = RestClient::Request.execute(method: :post, url: url, payload: payload, headers: headers)
      response_data = JSON.parse(response)
  
      # Check the ResultCode and return a clear status
      result_code = response_data['ResultCode']
      result_desc = response_data['ResultDesc']
  
      case result_code
      when '0'
        render json: { status: 'Success', message: result_desc }, status: :ok
      when '1032'
        render json: { status: 'UserCancelled', message: result_desc }, status: :ok
      when '1', '2'
        render json: { status: 'Failed', message: result_desc }, status: :ok
      else
        render json: { status: 'Pending', message: 'Payment is still pending.' }, status: :ok
      end
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "STK Query Request failed: #{e.response}"
      render json: { error: "STK Query request failed", details: e.response }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      render json: { error: "An unexpected error occurred" }, status: :internal_server_error
    end
  end
  

  private

  def generate_access_token_request
    consumer_key = ENV['MPESA_CONSUMER_KEY']
    consumer_secret = ENV['MPESA_CONSUMER_SECRET']
    url = 'https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'
    userpass = Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")

    headers = { Authorization: "Basic #{userpass}" }

    response = RestClient.get(url, headers)
    parsed_response = JSON.parse(response.body, symbolize_names: true)
    parsed_response[:access_token] || raise('Access token not found in response')
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "Request failed with response: #{e.response}"
    raise "Error generating access token: #{e.message}"
  end

  def get_access_token
    @access_token ||= begin
      new_token = generate_access_token_request
      AccessToken.find_or_initialize_by(id: 1).update!(token: new_token)
      Rails.logger.debug "New access token generated: #{new_token}"
      new_token
    end
  end

  def validate_phone_number(phone_number)
    phone_number.match?(/^2547\d{8}$/)
  end

  def update_customer_phonenumber(customer_phonenumber)
    @phoneNumber = customer_phonenumber
  end

  def process_callback(request_body)
    callback_data = JSON.parse(request_body)
    Rails.logger.debug "Received Callback Data: #{callback_data}"

    result_code = callback_data.dig('Body', 'stkCallback', 'ResultCode')
    result_desc = callback_data.dig('Body', 'stkCallback', 'ResultDesc')
    checkout_request_id = callback_data.dig('Body', 'stkCallback', 'CheckoutRequestID')

    if result_code == 0
      Rails.logger.info "Transaction Successful: #{result_desc}"
      # Process the successful transaction (e.g., update order status)
    else
      Rails.logger.warn "Transaction Failed: #{result_desc}"
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON format in callback data: #{e.message}"
  end
end
