class SessionsController < ApplicationController
  before_action :authorized_user, only: [:destroy]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = AuthenticationTokenService.encode(user.id)
      refresh_token = RefreshTokenService.encode(user.id)
      render json: { user: UserSerializer.new(user), token: token, refreshToken: refresh_token }, status: :created
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    if current_user || token_expired?
      render json: { message: 'Logged out successfully' }, status: :ok
    else
      render json: { message: "Couldn't find an active session or token has expired." }, status: :unauthorized
    end
  end

  def refresh
    refresh_token = request.headers['Authorization']&.split(' ')&.last
    decoded_refresh_token = RefreshTokenService.decode(refresh_token)

    if decoded_refresh_token
      user_id = decoded_refresh_token[:user_id]
      token = AuthenticationTokenService.encode(user_id)
      render json: { token: token }, status: :ok
    else
      render json: { message: 'Invalid or expired refresh token' }, status: :unauthorized
    end
  end

  private

  def current_user
    decoded = decoded_token
    if decoded && decoded[:user_id]
      @current_user ||= User.find_by(id: decoded[:user_id])
    else
      @current_user = nil
    end
  end

  def decoded_token
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

    AuthenticationTokenService.decode(token)
  end

  def token_expired?
    token = request.headers['Authorization']&.split(' ')&.last
    return false unless token

    begin
      decoded_token = JWT.decode(token, AuthenticationTokenService::HMAC_SECRET, true, algorithm: AuthenticationTokenService::ALGORITHM_TYPE)
      false
    rescue JWT::ExpiredSignature
      Rails.logger.info "Token has expired, but allowing logout."
      true
    rescue JWT::DecodeError
      Rails.logger.info "Invalid token."
      false
    end
  end

  def authorized_user
    unless current_user || token_expired?
      render json: { message: 'You need to log in to perform this action or token has expired.' }, status: :unauthorized
    end
  end
end
