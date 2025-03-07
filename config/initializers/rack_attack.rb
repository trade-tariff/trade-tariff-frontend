if Rails.env.production?
  Rack::Attack.throttle('requests by ip', limit: 500, period: 60, &:ip)
else
  Rails.logger.info 'Rack::Attack is disabled in Dev env.'
end
