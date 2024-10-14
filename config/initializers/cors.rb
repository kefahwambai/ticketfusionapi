Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    #  "http://localhost:3010", "http://localhost:4040"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
