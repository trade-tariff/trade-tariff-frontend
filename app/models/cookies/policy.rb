module Cookies
  class Policy
    include ActiveModel::Model

    attr_reader :usage, :remember_settings

    class << self
      def from_cookie(cookie)
        return new if cookie.blank?

        values = JSON.parse(cookie)

        new(values).tap(&:mark_persisted!)
      end
    end

    def usage=(value)
      @usage = value.presence
    end

    def usage?
      @usage.to_s == 'true'
    end

    def remember_settings=(value)
      @remember_settings = value.presence
    end

    def remember_settings?
      @remember_settings.to_s == 'true'
    end

    def settings
      true
    end

    def settings=(_)
      # no op
    end

    def settings?
      true
    end

    def acceptance=(value)
      return if value.blank?

      self.usage = (value == 'accept').to_s
      self.remember_settings = (value == 'accept').to_s
    end

    def to_cookie
      {
        settings: settings,
        usage: usage,
        remember_settings: remember_settings,
      }.to_json
    end

    def persisted?
      @persisted || false
    end

    def mark_persisted!
      @persisted = true
    end
  end
end
