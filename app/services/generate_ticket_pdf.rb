class GenerateTicketPdf
  def initialize(ticket)
    @ticket = ticket
    @event = @ticket.event
  end

  def generate
    Prawn::Fonts::AFM.hide_m17n_warning = true

    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: [50, 75, 50, 75])

    # Left section for ticket information (QR code and ticket number)
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 3) do
      pdf.text "ADMIT ONE", align: :center, size: 14, style: :bold
      pdf.move_down 10
      pdf.move_down 20

      # Generate QR Code and display it here
      qr_code_url = Rails.application.routes.url_helpers.validate_ticket_url(@ticket.identifier, host: 'localhost', port: 3000)
      qr_code = RQRCode::QRCode.new(qr_code_url)
      png = qr_code.as_png(size: 150)
      IO.binwrite("tmp/qrcode_left.png", png.to_s)
      pdf.image "tmp/qrcode_left.png", width: 100, height: 100, position: :center
      pdf.move_down 10

      pdf.text "Ticket Number: #{@ticket.identifier}", size: 10, align: :center
    end
    

    # Center section for event details
    pdf.bounding_box([pdf.bounds.width / 3, pdf.cursor], width: pdf.bounds.width / 3) do
      pdf.move_down 10
      pdf.text "#{@event.name.upcase}", style: :bold, size: 24, align: :center
      pdf.text "LIVE", style: :bold, size: 18, align: :center, color: "FF4500"
      pdf.move_down 10
      pdf.text "Location: #{@event.location}", align: :center, size: 10
      pdf.text "Date: #{@event.date.strftime('%B %d, %Y')}", align: :center, size: 10
    end

    # Right section for terms, QR code, and contact information
    pdf.bounding_box([2 * pdf.bounds.width / 3, pdf.cursor], width: pdf.bounds.width / 3) do
      pdf.move_down 10
      pdf.font_size 12
      pdf.text "Terms & Conditions", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 5
      terms = [
        "Management reserves the right to admission at the event.",
        "Only tickets bought through official channels are valid.",
        "All sales are final. No cancellations, refunds, or exchanges.",
        "Keep your ticket safe to avoid duplication.",
        "The holder of this ticket voluntarily assumes all risks.",
        "You can print your ticket or use it on your mobile phone.",
        "Once scanned, the ticket ceases to be valid."
      ]
      terms.each { |term| pdf.text "• #{term}", size: 8, inline_format: true }
      pdf.move_down 10

      # QR Code on the right section
      pdf.image "tmp/qrcode_left.png", width: 100, height: 100, position: :right
    end

    # Contact information
    pdf.move_down 20
    pdf.text "Support Information", size: 8, style: :bold
    pdf.text "Email: info@ticketfusion.com", size: 8
    pdf.text "Tel: +254 733 333 333 / +254 722 222 222", size: 8

    # Event image section (if available)
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
    end

    pdf.render
  end
end
