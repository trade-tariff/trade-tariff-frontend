require 'client_builder'

Rails.application.config.http_client_uk = ClientBuilder.new('uk', cache: Rails.cache).call
Rails.application.config.http_client_xi = ClientBuilder.new('xi', cache: Rails.cache).call
