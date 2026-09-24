if Rails.env.production?
  Rack::Attack.throttle('requests by ip', limit: 500, period: 60, &:ip)

  # Enqueue is non-idempotent and shares the default Sidekiq queue. Polls stay on the generic limit.
  Rack::Attack.throttle('queued guided search by ip', limit: 20, period: 60) do |request|
    request.ip if request.post? && request.path.match?(%r{/search/queued\z})
  end
end
