module CognitoTokenVerifier
  ISSUER = "https://cognito-idp.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['COGNITO_USER_POOL_ID']}".freeze
  JWKS_URL = "#{ISSUER}/.well-known/jwks.json".freeze

  def self.verify_id_token(token)
    return nil if token.blank?

    jwks_response = Faraday.get(JWKS_URL)

    return nil unless jwks_response.success?

    jwks_keys = JSON.parse(jwks_response.body)['keys']
    decoded_token = JWT.decode(token, nil, true,
                               algorithms: %w[RS256],
                               jwks: { keys: jwks_keys },
                               iss: ISSUER,
                               verify_iss: true,
                               aud: ENV['COGNITO_CLIENT_ID'],
                               verify_aud: true)

    decoded_token[0]
  rescue StandardError
    nil
  end
end
