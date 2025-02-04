if Rails.env.production?
  Rack::Attack.throttle('requests by ip', limit: 10_000, period: 600, &:ip)
else
  Rails.logger.info 'Rack::Attack is disabled in Dev env.'
end
