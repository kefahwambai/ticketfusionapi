# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    # Dashboard Summary
    columns do
      column do
        panel "Event Summary" do
          para "Total Events: #{Event.count}"
          para "Upcoming Events: #{Event.where('date > ?', Time.current).count}"
          para "Past Events: #{Event.where('date <= ?', Time.current).count}"
        end
      end

      column do
        panel "Ticket Summary" do
          para "Total Tickets: #{Ticket.count}"
          para "Available Tickets: #{Ticket.where(used: false).count}"
          para "Sold Tickets: #{Ticket.where(used: true).count}"
        end
      end

      column do
        panel "Sales Summary" do
          para "Total Sales: #{Sale.count}"
          para "Total Revenue: #{Sale.sum(:revenue).to_f.round(2)}"
        end
      end

      column do
        panel "User Summary" do
          para "Total Users: #{User.count}"
        end
      end
    end

    # Recent Events
    panel "Recent Events" do
      table_for Event.order(date: :desc).limit(5) do
        column("Name") { |event| link_to event.name, admin_event_path(event) }
        column("Date") { |event| event.date.strftime("%B %d, %Y") }
        column("Location") { |event| event.location }
      end
    end
  end # content
end
