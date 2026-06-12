RoutingFilter::Locale.include_default_locale = false
I18n.available_locales = %i[en]
I18n.available_locales << :cy if ENV['WELSH'].to_s == 'true'
I18n.default_locale = :en
Rails.application.config.i18n.fallbacks = true
