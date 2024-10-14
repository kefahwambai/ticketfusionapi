class TicketMailer < ApplicationMailer
  def ticket_email(email, ticket)
    @ticket = ticket
    pdf = GenerateTicketPdf.new(ticket).generate
    attachments["#{ticket.name}.pdf"] = pdf
    mail(to: email, subject: "#{ticket.name} Ticket for #{ticket.event}") do |format|
      format.text { render plain: 'Please find your ticket attached.' }
    end
  end
end
