module TradeTariffFrontend
  class BasicAuth < Rack::Auth::Basic
    def call(env)
      request = Rack::Request.new(env)

      if !TradeTariffFrontend.basic_auth? || request.path.match(/^\/healthcheck/)
        @app.call(env)
      else
        super
      end
    end
  end
end
