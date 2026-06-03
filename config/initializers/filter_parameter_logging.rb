# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc, :ssn, :email,
  'feedback.name', 'feedback.message',
  :query, :other_category, :goods_product, :goods_made_of, :goods_used_for, :goods_function,
  :goods_processed, :goods_packaged, :commodity_code, :full_name, :company_name, :occupation
]
