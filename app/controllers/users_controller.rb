class UsersController < ApplicationController
  before_action :authenticate_request!, only: [:current]

  def index
    users = User.includes(events: :tickets).all
    render json: users, include: ['events.tickets']
  end
  
  def show
    user = User.includes(events: :tickets).find(params[:id])
    render json: user, include: ['events.tickets']
  end


  def current
    if @current_user
      render json: @current_user, include: ['events.tickets']
    else
      render json: { message: 'No user found' }, status: :not_found
    end
  end
  
  

  def create
    user = User.create!(user_params)
    token = AuthenticationTokenService.encode(user.id)
    render json: { token: token }, status: :created
  end



  def destroy
    user = User.find(params[:id])
    if user.destroy
      render json: { message: 'User deleted successfully' }
    else
      render json: { errors: 'Failed to delete user!' }, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.permit(:business_name, :name, :email, :password, :phone_number)
    end
    
end
