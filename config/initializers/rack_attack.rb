if Rails.env.production?
  Rack::Attack.throttle('requests by ip', limit: 500, period: 60, &:ip)
end

# Exempt Flipper Cloud webhook callbacks from rate limiting.
# Flipper::Engine mounts the webhook receiver at /_flipper (POST).
# Guard with defined? because rack-attack is only bundled in production.
if defined?(Rack::Attack)
  Rack::Attack.safelist('allow-flipper-webhooks') do |req|
    req.path.start_with?('/_flipper') && req.post?
  end
end
