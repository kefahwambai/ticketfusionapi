Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://ticketfusion-admin.vercel.app", "https://jtickets.vercel.app",
     "http://localhost:3010", "http://localhost:4040"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
