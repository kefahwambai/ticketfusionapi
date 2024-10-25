ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
  Rails.logger.info "[Rack::Attack] - Throttle #{payload[:request].ip}"
end

class Rack::Attack
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/login' && req.post?
  end

  throttle('signups/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/signup' && req.post?
  end

  Rack::Attack.track("login_abuse") do |req|
    req.ip if req.path == '/login' && req.post?
  end

  self.throttled_responder = lambda do |env|
     { 'Content-Type' => 'application/json' },
     [{ error: 'Rate limit exceeded. Try again later.' }.to_json]]
  end
end
