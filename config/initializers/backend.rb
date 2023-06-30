require 'client_builder'

Rails.application.config.http_client_uk = ClientBuilder.new('uk', cache: Rails.cache).call
Rails.application.config.http_client_xi = ClientBuilder.new('xi', cache: Rails.cache).call
Rails.application.config.http_client_uk_forwarding = ClientBuilder.new('uk', forwarding: true).call
Rails.application.config.http_client_xi_forwarding = ClientBuilder.new('xi', forwarding: true).call
