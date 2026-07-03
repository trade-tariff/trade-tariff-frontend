module TradeTariffFrontend
  # Decorates TradeTariffFrontend::Config methods with Flagsmith-backed overrides.
  #
  # A config method remains the source of truth for the default value. Register it
  # with `flagsmith_flag` to allow a configured Flagsmith value to override that
  # default for the selected service(s):
  #
  #   def interactive_search_enabled?
  #     !production? && !ServiceChooser.xi?
  #   end
  #
  #   flagsmith_flag :interactive_search_enabled?,
  #                  name: :interactive_search,
  #                  services: %i[uk]
  #
  # If Flagsmith has no value, no request identity is available, or Flagsmith
  # cannot be reached, the original config method value is returned. Registered
  # flags are also exposed through Config::RegisteredFlags so controllers can
  # include only the flag helpers rather than the full config module.
  module FlagsmithBackedConfig
    FALLBACK_EVENT = 'flagsmith.config_flag_fallback'.freeze

    def self.prepended(base)
      base.const_set(:RegisteredFlags, Module.new) unless base.const_defined?(:RegisteredFlags, false)
      base.extend ClassMethods
    end

    module ClassMethods
      def registered_flags
        @registered_flags ||= {}
      end

      def flagsmith_flag(method_name, name:, services: nil, optin: false)
        flag_name = name.to_s
        service_names = Array(services).map(&:to_s)
        registered_flags[method_name] = { name: flag_name, services: service_names, optin: optin }

        TradeTariffFrontend::FlagsmithBackedConfig.define_method(method_name) do
          default = super()
          next default unless service_names.empty? || service_names.include?(TradeTariffFrontend::ServiceChooser.service_name)

          flagsmith_config_flag(flag_name, method_name:, default:)
        end

        registered_flags_module.define_method(method_name) do
          TradeTariffFrontend.public_send(method_name)
        end
        registered_flags_module.module_eval { private method_name }
      end

      private

      def registered_flags_module
        const_get(:RegisteredFlags)
      end
    end

    private

    def flagsmith_config_flag(flag_name, method_name:, default:)
      unless FlagsmithClient.configured?
        instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason: :not_configured)
        return default
      end

      if Current.flagsmith_unavailable
        instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason: :previously_unavailable)
        return default
      end

      if Current.flagsmith_identity.blank?
        instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason: :missing_identity)
        return default
      end

      flags = Current.flagsmith_flags ||= FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)
      flag = flags.get_flag(flag_name)

      if flag.is_default
        instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason: :missing_flag)
        default
      else
        flag.enabled?
      end
    rescue StandardError => e
      Current.flagsmith_unavailable = true
      instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason: :unavailable, error: e)
      Rails.logger.warn("Flagsmith unavailable, using default for #{flag_name}: #{e.class}: #{e.message}")
      default
    end

    def instrument_flagsmith_config_fallback(flag_name:, method_name:, default:, reason:, error: nil)
      payload = {
        flag_name:,
        method_name:,
        default:,
        reason:,
        service_name: TradeTariffFrontend::ServiceChooser.service_name,
        environment: TradeTariffFrontend.environment,
      }
      payload[:error_class] = error.class.name if error

      ActiveSupport::Notifications.instrument(FALLBACK_EVENT, payload)
    end
  end
end
