class EventsController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]
  before_action :authorize_event_access!, only: [:show, :update, :destroy]

  def index
    render json: Event.all, status: :ok
  end

  def show
    event = Event.includes(:tickets).find_by(id: params[:id])
    if event
      event_data = event.as_json
      event_data[:image_url] = event.image.url if event.image.present?
      render json: event_data, status: :ok
    else
      render json: { error: 'Event not found or unauthorized.' }, status: :not_found
    end
  end

  def create
    event = Event.new(event_params)
    event.user = @current_user

    if event.save
      render json: event, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find_by(id: params[:id])
    
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found
    elsif event.update(event_params)
      render json: event, status: :ok
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find_by(id: params[:id])
    
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found
    elsif event.destroy
      render json: { message: 'Event deleted' }, status: :ok
    else
      render json: { errors: 'Event could not be deleted' }, status: :unprocessable_entity
    end
  end

  private

  def authorize_event_access!
    event = Event.find_by(id: params[:id])
    if @current_user && event&.user != @current_user
      render json: { error: 'Access denied' }, status: :forbidden
    end
  end

  def event_params
    params.require(:event).permit(:name, :description, :date, :location, :image)
  end
end
