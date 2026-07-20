require 'digest'

module TradeTariffFrontend
  class ExperimentUrls
    include Enumerable

    ConfigurationError = Class.new(StandardError)
    FIELDS = %i[path feature starts_on ends_on timezone redirect service instrumentation_label].freeze
    INTERNAL_PATH = %r{\A/(?!/)[^\p{Space}?#\\]*\z}
    LITERAL_PATH = %r{\A/(?!/)[^\p{Space}?#\\:*()]*\z}
    LABEL = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
    KEY = /\A[a-z0-9]+(?:_[a-z0-9]+)*\z/

    Entry = Data.define(:key, :path, :feature_name, :starts_on, :ends_on, :timezone,
                        :redirect_path, :service, :instrumentation_label, :enrollment_token) do
      def state_at(time, service_name:)
        return :wrong_service unless service == service_name.to_s

        date = time.in_time_zone(timezone).to_date
        return :not_started if date < starts_on
        return :expired if date > ends_on

        :active
      end

      def expired_at?(time)
        time.in_time_zone(timezone).to_date > ends_on
      end
    end

    def initialize(raw_config, registered_flags:, service_names:)
      config = hash!(raw_config, 'configuration')
      raise ConfigurationError, 'configuration must contain at most 20 entries' if config.size > 20

      flags = registered_flags.to_h.values.map { |metadata| metadata.to_h.with_indifferent_access }
      entries = config.map do |key, raw_entry|
        error!(key, :key, 'must be at most 64 lowercase snake-case characters') unless key.to_s.length <= 64 && key.to_s.match?(KEY)
        attributes = hash!(raw_entry, "entry #{key}").with_indifferent_access
        FIELDS.each { |field| error!(key, field, 'is required') if attributes[field].blank? }

        path = attributes[:path].to_s
        redirect = attributes[:redirect].to_s
        error!(key, :path, 'must be an absolute literal route path') unless path.match?(LITERAL_PATH)
        error!(key, :redirect, 'must be an absolute internal path') unless redirect.match?(INTERNAL_PATH)

        feature = attributes[:feature].to_s
        flag = flags.find { |metadata| metadata[:name].to_s == feature }
        error!(key, :feature, 'must be a registered opt-in flag') unless flag&.fetch(:optin, false)

        service = attributes[:service].to_s
        error!(key, :service, 'is not configured') unless service_names.map(&:to_s).include?(service)
        error!(key, :service, "is not supported by feature #{feature}") unless Array(flag[:services]).map(&:to_s).include?(service)

        starts_on = date!(attributes[:starts_on], key, :starts_on)
        ends_on = date!(attributes[:ends_on], key, :ends_on)
        error!(key, :ends_on, 'must be on or after starts_on') if ends_on < starts_on
        timezone = attributes[:timezone].to_s
        error!(key, :timezone, 'must be a valid IANA timezone') unless ActiveSupport::TimeZone[timezone]

        label = attributes[:instrumentation_label].to_s
        error!(key, :instrumentation_label, 'must be a lowercase hyphenated label') unless label.length <= 64 && label.match?(LABEL)
        token = "#{key}:#{Digest::SHA256.hexdigest(FIELDS.map { |field| attributes[field] }.to_json).first(16)}"
        Entry.new(key: key.to_s.freeze, path: path.freeze, feature_name: feature.freeze,
                  starts_on:, ends_on:, timezone: timezone.freeze, redirect_path: redirect.freeze,
                  service: service.freeze, instrumentation_label: label.freeze,
                  enrollment_token: token.freeze).freeze
      end

      duplicate!(entries, :path)
      duplicate!(entries, :key)
      duplicate!(entries, :instrumentation_label)
      paths = entries.index_by(&:path)
      entries.each { |entry| error!(entry.key, :redirect, 'must not target an experiment URL') if paths.key?(entry.redirect_path) }
      @entries = entries.freeze
      @by_key = entries.index_by(&:key).freeze
      @by_token = entries.index_by(&:enrollment_token).freeze
      freeze
    end

    def each(&) = @entries.each(&)
    def fetch(key) = @by_key.fetch(key.to_s)
    def find_by_enrollment_token(token) = @by_token[token.to_s]

    private

    def hash!(value, context)
      return value.to_h if value.respond_to?(:each_pair)

      raise ConfigurationError, "#{context} must be a key-value object"
    end

    def date!(value, key, field)
      Date.iso8601(value.to_s)
    rescue Date::Error
      error!(key, field, 'must be an ISO8601 date')
    end

    def duplicate!(entries, field)
      duplicate = entries.group_by(&field).find { |_, matches| matches.many? }
      error!(duplicate.last.last.key, field, "duplicates #{duplicate.first}") if duplicate
    end

    def error!(key, field, message)
      raise ConfigurationError, "entry #{key} field #{field} #{message}"
    end
  end
end
