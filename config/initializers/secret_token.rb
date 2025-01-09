# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

TradeTariffFrontend::Application.config.secret_token = ENV['SECRET_TOKEN']
TradeTariffFrontend::Application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'DRP57/m3nTx1UEQ0qAo0IsCKZgKDvu8W+U/8hTO7jPY=')
