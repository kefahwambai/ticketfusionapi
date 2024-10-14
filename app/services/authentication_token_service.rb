class AuthenticationTokenService
  HMAC_SECRET = Rails.application.secrets.secret_key_base
  ALGORITHM_TYPE = 'HS256'.freeze

  def self.encode(user_id)
    exp = 30.minutes.from_now.to_i
    payload = { user_id: user_id, exp: exp }
    JWT.encode(payload, HMAC_SECRET, ALGORITHM_TYPE)
  end

  def self.decode(token)
    begin
      decoded_token = JWT.decode(token, HMAC_SECRET, true, algorithm: ALGORITHM_TYPE)[0]
       Rails.logger.debug "Decoded token: #{decoded_token.inspect}"
      HashWithIndifferentAccess.new(decoded_token)
    rescue JWT::ExpiredSignature
      Rails.logger.info "Token has expired"
      nil
    rescue JWT::DecodeError => e
      Rails.logger.info "Invalid token: #{e.message}"
      nil
    end
  end

  def self.valid_payload(payload)
    return false unless payload.is_a?(Hash)
    
    exp = payload['exp']
    Rails.logger.debug "Token expiration time: #{exp}, Current time: #{Time.now.to_i}"
    exp && exp > Time.now.to_i
  end
end
