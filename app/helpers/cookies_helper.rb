module CookiesHelper
  def policy_cookie
    cookie = cookies['cookies_policy']

    cookie.present? ? JSON.parse(cookie) : {}
  end

  def cookie_confirmation_class
    @updated_cookies ? 'show' : 'hide'
  end
end
