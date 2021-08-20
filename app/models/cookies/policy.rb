module Cookies
  class Policy
    include ActiveModel::Model

    attr_reader :usage, :remember_settings

    class << self
      def find(cookie)
        return new if cookie.blank?

        values = JSON.parse(cookie)

        new values.slice('usage', 'remember_settings')
      end
    end

    def usage=(value)
      @usage = value.presence
    end

    def remember_settings=(value)
      @remember_settings = value.presence
    end

    def settings
      true
    end

    def settings=(_)
      # no op
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
  end
end
