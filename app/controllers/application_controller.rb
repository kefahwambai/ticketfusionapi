class ApplicationController < ActionController::Base
  include Response
  include ExceptionHandler
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  rescue_from ActiveRecord::RecordNotDestroyed, with: :not_destroyed

  def authenticate_request!
    token = request.headers['Authorization']&.split(' ')&.last
    Rails.logger.debug("Token from header: #{token.inspect}")
  
    if token.present?
      decoded_token = AuthenticationTokenService.decode(token)
      Rails.logger.debug("Decoded token: #{decoded_token.inspect}")
  
      if decoded_token && decoded_token['user_id']
        @current_user = User.find_by(id: decoded_token['user_id'])
        Rails.logger.debug("Current user found: #{@current_user.inspect}")
      else
        Rails.logger.debug("No user ID found in decoded token")
      end
    else
      Rails.logger.debug("No token present")
    end
  
    unless @current_user
      render json: { message: 'Invalid or missing token' }, status: :unauthorized unless action_name == 'index' || action_name == 'show'
    end
  end
   

  private

  def payload
    auth_header = request.headers['Authorization']
    if auth_header
      token = auth_header.split(' ').last
      # Rails.logger.debug "Token extracted: #{token}"
      decoded_token = AuthenticationTokenService.decode(token)
      # Rails.logger.debug "Decoded token: #{decoded_token.inspect}" 
      decoded_token
    else
      Rails.logger.debug "No Authorization header found"
      nil
    end
  end
  

  def invalid_authentication
    render json: { error: 'You will need to login first' }, status: :unauthorized
  end
end
