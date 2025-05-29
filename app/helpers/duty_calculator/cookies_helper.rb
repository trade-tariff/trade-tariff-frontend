module DutyCalculator
  module CookiesHelper
    def policy_cookie
      cookie = cookies['cookies_policy']

      cookie.present? ? JSON.parse(cookie) : {}
    end

    def usage_enabled?
      policy_cookie['usage'] == 'true'
    end
  end
end
