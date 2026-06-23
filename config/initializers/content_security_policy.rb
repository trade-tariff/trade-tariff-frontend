# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.connect_src :self, :https, :blob,
                       'https://www.google-analytics.com',
                       'https://analytics.google.com',
                       'https://region1.google-analytics.com'
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data,
                       'https://www.google-analytics.com',
                       'https://www.googletagmanager.com'
    policy.object_src  :none
    # unsafe-eval and strict-dynamic are required by Google Tag Manager
    policy.script_src  :self, :https, :unsafe_eval, :strict_dynamic
    policy.style_src   :self, :https, :blob, :unsafe_inline
    # Specify URI for violation reports
    policy.report_uri '/csp-violation-report'
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true
end
