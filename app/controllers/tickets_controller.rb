class TicketsController < ApplicationController
  before_action :authenticate_request!, only: [:create, :update, :destroy, :download_ticket]

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
    ticket = Ticket.find_by(id: params[:id])
    if ticket.nil?
      render json: { error: 'Ticket not found' }, status: :not_found
    else
      render json: ticket, status: :ok
    end
  end

  def download_ticket
    ticket = Ticket.find_by(id: params[:id])
    if ticket.nil?
      render json: { error: 'Ticket not found' }, status: :not_found
      return
    end
  
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
  

  def validate_ticket
    ticket = Ticket.find_by(id: params[:id])
    if ticket.nil?
      render json: { valid: false, message: 'Ticket not found' }, status: :not_found
    elsif ticket.used
      render json: { valid: false, message: 'Ticket has already been used' }, status: :unprocessable_entity
    else
      render json: { valid: true, message: 'Ticket is valid', ticket: ticket }, status: :ok
    end
  end
  

  private

  def ticket_params
    params.require(:ticket).permit(:event_id, :name, :ticket_type, :price, :max_quantity, :start_time, :end_time, :is_group_ticket, :group_size, :total_tickets)
  end
end
