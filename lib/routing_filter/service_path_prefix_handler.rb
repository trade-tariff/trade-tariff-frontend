require 'trade_tariff_frontend'

module RoutingFilter
  class ServicePathPrefixHandler < Filter
    SERVICE_CHOICE_PREFIXES =
      ::TradeTariffFrontend::ServiceChooser.service_choices
                                           .keys
                                           .map { |prefix| Regexp.escape(prefix) }
                                           .join('|')
                                           .freeze

    SERVICE_CHOICE_PREFIXES_REGEX = %r{^/(#{SERVICE_CHOICE_PREFIXES})(?=/|$)}

    # Recognising paths
    def around_recognize(path, _env)
      service_choice = extract_segment!(SERVICE_CHOICE_PREFIXES_REGEX, path)

      ::TradeTariffFrontend::ServiceChooser.service_choice = service_choice

      yield
    end

    # Rendering links
    def around_generate(_params)
      yield.tap do |result, _params|
        service_choice = ::TradeTariffFrontend::ServiceChooser.service_choice

        if service_choice.present? && service_choice != service_choice_default
          prepended_url = prepend_segment(result.url, service_choice)

          # rubocop:disable Rails/SaveBang
          result.update(prepended_url)
          # rubocop:enable Rails/SaveBang
        end
      end
    end

    private

    def service_choice_default
      ::TradeTariffFrontend::ServiceChooser.service_default
    end
  end
end
