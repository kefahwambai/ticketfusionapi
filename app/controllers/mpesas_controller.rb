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
    process_callback(request_body)
    render json: { status: 'success' }
  end   

  # STK Push method to initiate a transaction
  def stkpush
    phoneNumber = params[:phoneNumber]
    amount = params[:amount]

    # Validate the phone number format
    unless validate_phone_number(phoneNumber)
      render json: { error: 'Invalid phone number format' }, status: :bad_request
      return
    end

    # STK Push API URL
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    timestamp = Time.now.strftime "%Y%m%d%H%M%S"
    business_short_code = ENV["MPESA_SHORT_CODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")

    # Payload for STK push request
    payload = {
      'BusinessShortCode': business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': "CustomerPayBillOnline",
      'Amount': amount,
      'PartyA': phoneNumber,
      'PartyB': business_short_code,
      'PhoneNumber': phoneNumber,
      'CallBackURL': "#{ENV["CALLBACK_URL"]}/callback",
      'AccountReference': 'Codearn',
      'TransactionDesc': "Payment for Codearn premium"
    }.to_json

    # Headers for the request
    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }

    # Make the STK push request
    response = RestClient::Request.new({
      method: :post,
      url: url,
      payload: payload,
      headers: headers
    }).execute do |response, request|
      case response.code
      when 500
        [:error, JSON.parse(response.to_str)]
      when 400
        [:error, JSON.parse(response.to_str)]
      when 200
        [:success, JSON.parse(response.to_str)]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end

    render json: response
  end

  # STK Query method to check the status of the transaction
  def stkquery
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"
    timestamp = Time.now.strftime "%Y%m%d%H%M%S"
    business_short_code = ENV["MPESA_SHORT_CODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")

    # Payload for STK query request
    payload = {
      'BusinessShortCode': business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'CheckoutRequestID': params[:checkoutRequestID]
    }.to_json

    # Headers for the request
    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }

    # Make the STK query request
    response = RestClient::Request.new({
      method: :post,
      url: url,
      payload: payload,
      headers: headers
    }).execute do |response, request|
      case response.code
      when 500
        [:error, JSON.parse(response.to_str)]
      when 400
        [:error, JSON.parse(response.to_str)]
      when 200
        [:success, JSON.parse(response.to_str)]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end

    render json: response
  end

  private

  # Generates the access token required for API requests
  def generate_access_token_request
    @url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    @consumer_key = ENV['MPESA_CONSUMER_KEY']
    @consumer_secret = ENV['MPESA_CONSUMER_SECRET']

    @userpass = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")

    headers = {
      Authorization: "Basic #{@userpass}"
    }

    res = RestClient::Request.execute(url: @url, method: :get, headers: headers)
    res
  end

  # Retrieves or generates a new access token
  def get_access_token
    res = generate_access_token_request
    
    unless res.code == 200
      raise MpesaError.new('Unable to generate access token')
    end

    body = JSON.parse(res.body, symbolize_names: true)
    token = body[:access_token]

    # Store the new token in the database
    AccessToken.destroy_all
    AccessToken.create!(token: token)

    token
  end

  # Validates the phone number format to ensure it follows Mpesa standards
  def validate_phone_number(phone_number)
    # Ensure the phone number starts with '2547' and is 12 digits long
    phone_number.match?(/^2547\d{8}$/)
  end

  # Updates the customer phone number from the order event
  def update_customer_phonenumber(customer_phonenumber)
    @phoneNumber = customer_phonenumber
  end

  # Processes the callback from the Mpesa API
  def process_callback(request_body)
    # Implement the logic to handle the callback data
    # Example: save the transaction details in the database, verify status, etc.
    callback_data = JSON.parse(request_body)
    # Your callback processing logic here
  end
end
