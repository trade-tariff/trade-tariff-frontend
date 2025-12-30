if Rails.env.production?
  Rack::Attack.throttle('requests by ip', limit: 500, period: 60, &:ip)
end
