module FlagsmithSetup
  extend ActiveSupport::Concern

  private

  def set_current_flagsmith_identity
    Current.flagsmith_identity = current_flagsmith_identity
    Current.experiment = nil

    traits = session[:flagsmith_optin_traits]
    Current.flagsmith_optin_traits = traits.is_a?(Hash) ? traits.to_h.transform_keys(&:to_s) : {}

    resolve_experiment_url_optins
  end

  def resolve_experiment_url_optins
    now = Time.current
    service_name = TradeTariffFrontend::ServiceChooser.service_name
    active = active_experiment_enrollments(at: now, service_name:)
    active.each do |experiment|
      Current.flagsmith_optin_traits[experiment.feature_name] = { value: true, transient: true }
    end
    Current.experiment = active.last&.instrumentation_label
  end

  def current_flagsmith_identity
    Flagsmith::AnonymousIdentity.new(anonymous_flagsmith_id)
  end

  def anonymous_flagsmith_id
    return cookies[:flagsmith_anonymous_id] if cookies[:flagsmith_anonymous_id].present?

    uuid = SecureRandom.uuid
    cookies[:flagsmith_anonymous_id] = {
      value: uuid,
      max_age: 1.year.to_i,
      httponly: true,
      secure: Rails.env.production?,
    }
    uuid
  end
end
