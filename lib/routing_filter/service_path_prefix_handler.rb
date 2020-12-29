require 'trade_tariff_frontend'

module RoutingFilter
  class ServicePathPrefixHandler < Filter
    SERVICE_CHOICE_PREFIXES = 
      ::TradeTariffFrontend::ServiceChooser.service_choices
                                           .keys
                                           .map { |prefix| Regexp.escape(prefix) }
                                           .join('|')
                                           .freeze

    SERVICE_CHOICE_PREFIXES_REGEX = %r{^/(#{SERVICE_CHOICE_PREFIXES})(?=/|$)}.freeze

    # Recognising paths
    def around_recognize(path, _env)
      service_choice = extract_segment!(SERVICE_CHOICE_PREFIXES_REGEX, path)

      ::TradeTariffFrontend::ServiceChooser.service_choice = service_choice

      yield
    end

    # Rendering links
    def around_generate(_params)
      yield.tap do |path, _params|
        service_choice = ::TradeTariffFrontend::ServiceChooser.service_choice

        prepend_segment!(path, service_choice) if service_choice.present? && service_choice != service_choice_default
      end
    end

    private

    attr_reader :path, :service_choice

    def service_choice_default
      ::TradeTariffFrontend::ServiceChooser.service_default
    end
  end
end
