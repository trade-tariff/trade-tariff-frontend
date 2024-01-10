# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self, '*.googletagmanager.com'
    policy.style_src  :self
    # Specify URI for violation reports
    policy.report_uri ENV['SENTRY_CSP_ENDPOINT'] if ENV['SENTRY_CSP_ENDPOINT'].present?
  end
end
