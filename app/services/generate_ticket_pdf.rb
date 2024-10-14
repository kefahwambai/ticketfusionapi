class GenerateTicketPdf
  def initialize(ticket)
    @ticket = ticket
    @event = @ticket.event
  end

  def generate
    Prawn::Fonts::AFM.hide_m17n_warning = true

    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: [50, 75, 50, 75])

    pdf.move_down 10
    pdf.font_size 16
    pdf.text "#{@ticket.name} Ticket", size: 16, style: :bold      
    text_width = pdf.width_of("#{@ticket.name} Ticket")
    text_height = 20  

    pdf.stroke_rectangle [pdf.cursor - text_height, pdf.bounds.left], text_width, text_height
    pdf.move_down 30

    pdf.font_size 18
    pdf.text "#{@event.name.upcase}", style: :bold, color: "FF4500", align: :center
    pdf.move_down 5
    pdf.text "#{@event.date.strftime('%d/%m/%Y')} - #{@event.location}", size: 10, align: :center
    pdf.move_down 50

    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2 - 10) do
        if @event.image.present?
          image_path = @event.image.path
          if File.exist?(image_path)
            pdf.image image_path, width: 300, height: 300, position: :left
          else
            pdf.text "Image not available", size: 12, style: :italic, align: :left
          end
        else
          pdf.text "Event Image: Not available", size: 12, style: :italic, align: :left
        end
      end
      
      pdf.move_down 90
      pdf.bounding_box([pdf.bounds.width / 2 + 10, pdf.cursor + 200], width: pdf.bounds.width / 2 - 10) do
        qr_code_url = Rails.application.routes.url_helpers.validate_ticket_url(@ticket.id, host: 'localhost', port: 3010)
        qr_code = RQRCode::QRCode.new(qr_code_url)
        png = qr_code.as_png(size: 200)
        IO.binwrite("tmp/qrcode.png", png.to_s)
        pdf.image "tmp/qrcode.png", width: 120, height: 120, position: :right
      end
    end

    pdf.move_down 50

    pdf.font_size 12
    pdf.text "Order Information", style: :bold, color: "008080"
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.text "Payment Status: Delivered", style: :bold, color: "28A745"
    pdf.move_down 10

    pdf.font_size 8
    pdf.text "Terms and Conditions", size: 8, style: :bold, color: "D9534F"
    pdf.move_down 10
    terms = [
      "Management reserves the right to admission at the event.",
      "Only tickets bought through official channels are valid.",
      "All sales are final. No cancellations, refunds, or exchanges.",
      "Keep your ticket safe to avoid duplication.",
      "The holder of this ticket voluntarily assumes all risks.",
      "You can print your ticket or use it on your mobile phone.",
      "Once scanned, the ticket ceases to be valid."
    ]
    terms.each { |term| pdf.text "• #{term}", size: 8 }
    pdf.move_down 30

    pdf.text "Support Information", size: 8, style: :bold, color: "0A74DA"
    pdf.move_down 10
    pdf.text "Email: info@ticketfusion.com", size: 8
    pdf.text "Tel: +254 733 333 333 / +254 722 222 222", size: 8
    pdf.move_down 20

    pdf.number_pages "<page> of <total>", at: [pdf.bounds.right - 50, 0], align: :right, size: 12     

    pdf.render 
  end
end
