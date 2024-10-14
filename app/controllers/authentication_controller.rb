class AuthenticationController < ApplicationController
  def refresh
    auth_header = request.headers['Authorization']
    if auth_header.present?
      token = auth_header.split(' ').last
      decoded_token = AuthenticationTokenService.decode(token)
      if decoded_token
        new_token = AuthenticationTokenService.encode(decoded_token['user_id'])
        render json: { token: new_token }, status: :ok
      else
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  end
end