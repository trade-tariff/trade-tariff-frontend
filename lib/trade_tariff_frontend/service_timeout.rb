module TradeTariffFrontend
  class ServiceTimeout
    DEFAULT_PATH_OVERRIDES = '/uk/search:50,/xi/search:50,/search:50'.freeze

    def initialize(app)
      @app = app
      @default_timeout = ENV.fetch('RACK_TIMEOUT_SERVICE_TIMEOUT', '15').to_i
      @path_timeouts = parse_path_timeouts
    end

    def call(env)
      timeout = timeout_for(env['PATH_INFO'])
      ::Timeout.timeout(timeout) { @app.call(env) }
    end

    private

    def timeout_for(path)
      @path_timeouts.each do |prefix, seconds|
        return seconds if path.start_with?(prefix)
      end
      @default_timeout
    end

    def parse_path_timeouts
      ENV.fetch('RACK_TIMEOUT_PATH_OVERRIDES', DEFAULT_PATH_OVERRIDES)
         .split(',')
         .filter_map do |entry|
           parts = entry.strip.split(':')
           next if parts.length < 2

           [parts[0], parts[1].to_i]
         end
    end
  end
end
