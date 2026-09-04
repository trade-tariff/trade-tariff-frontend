module GuidedSearch
  class FailureSuggestions
    CODE_PATTERN = /\A[a-z0-9_]{1,64}\z/
    SUPPORTED_LEVELS = %w[warn].freeze
    ConfigurationError = Class.new(StandardError)

    def initialize(
      config: Rails.application.config.search_failure_messages,
      logger: Rails.logger
    )
      @config = config.to_h.deep_stringify_keys
      @logger = logger
      validate_configuration!
    end

    def messages_for(codes)
      messages = known_codes(codes).filter_map do |code|
        entry = @config[code]
        I18n.t(entry.fetch('translation_key')) if entry&.fetch('enabled', false)
      end
      messages.uniq
    end

    def known_codes(codes)
      known = Array(codes).filter_map do |code|
        normalized_code = code if code.is_a?(String) && code.match?(CODE_PATTERN)
        next normalized_code if @config.key?(normalized_code)

        @logger.warn(
          { event: 'guided_search.unknown_failure_code', failure_code: normalized_code || 'invalid' }.to_json,
        )
        nil
      end
      known.uniq
    end

    private

    def validate_configuration!
      @config.each do |code, entry|
        unless code.match?(CODE_PATTERN)
          raise ConfigurationError, "#{code} must be a valid failure code"
        end

        unless [true, false].include?(entry['enabled'])
          raise ConfigurationError, "#{code} must define enabled as a boolean"
        end

        if entry['translation_key'].blank?
          raise ConfigurationError, "#{code} must define translation_key"
        end

        next if SUPPORTED_LEVELS.include?(entry['level'])

        raise ConfigurationError, "#{code} has an unsupported level"
      end
    end
  end
end
