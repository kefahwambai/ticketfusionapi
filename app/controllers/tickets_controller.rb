class TicketsController < ApplicationController
  before_action :authenticate_request!, only: [:create, :update, :destroy, :download_ticket]
  before_action :set_ticket, only: [:validate, :download_ticket, :show]


  def index
    event = Event.find_by(id: params[:event_id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found
      return
    end

    tickets = event.tickets
    render json: tickets, status: :ok
  end

  def create
    event = Event.find_by(id: ticket_params[:event_id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found
      return
    end

    ticket = Ticket.new(ticket_params)
    ticket.event = event

    if ticket.save
      render json: ticket, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: ticket, status: :ok 
  end

  def download_ticket

    begin
      generator = GenerateTicketPdf.new(ticket)
      pdf_file = generator.generate
      send_file pdf_file.path, type: 'application/pdf', disposition: 'attachment'
    rescue => e
      render json: { error: "Failed to generate ticket: #{e.message}" }, status: :internal_server_error
    ensure
      pdf_file.close if pdf_file 
    end
  end

  def validate
    if @ticket.validated_at.nil?
      # Mark the ticket as validated by setting the current timestamp
      @ticket.update(validated_at: Time.current)
      render json: { status: 'success', message: 'Ticket is valid and will now marked as used.' }
    else
      render json: { status: 'error', message: 'Ticket has already been validated.' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: 'Ticket not found.' }, status: :not_found
  end
    

  private

  def set_ticket
    @ticket = Ticket.find_by(identifier: params[:id])  # Assuming identifier is the UUID and passed as :id
    render json: { error: 'Ticket not found' }, status: :not_found if @ticket.nil?
  end

  def ticket_params
    params.require(:ticket).permit(:event_id, :identifier, :name, :ticket_type, :price, :max_quantity, :start_time, :end_time, :is_group_ticket, :group_size, :total_tickets)
  end
end
