module FlagsmithSetup
  extend ActiveSupport::Concern

  FLAGSMITH_SAMPLE_EXPERIMENT = 'tenpct'.freeze
  INTERACTIVE_SEARCH_FLAG = 'interactive_search'.freeze

  private

  def set_current_flagsmith_identity
    Current.flagsmith_identity = current_flagsmith_identity
    Current.experiment = nil
    Current.experiment_url = nil

    Current.flagsmith_request_traits = {}
    if Current.request_country.present?
      Current.flagsmith_request_traits['request_country'] = { value: Current.request_country.to_s, transient: true }
    end

    resolve_experiment_url_optins
  end

  def resolve_experiment_url_optins
    now = Time.current
    service_name = TradeTariffFrontend::ServiceChooser.service_name
    active = active_experiment_enrollments(at: now, service_name:)
    active.each do |experiment|
      Current.flagsmith_request_traits[experiment.feature_name] = { value: true, transient: true }
    end
    enrolled = active.last
    Current.experiment = enrolled&.instrumentation_label
    Current.experiment_url = enrolled&.path
  end

  def assign_flagsmith_sample_experiment
    return if Current.experiment.present?
    return if flagsmith_interactive_search_opted_in?

    evaluation = Current.flagsmith_evaluations[INTERACTIVE_SEARCH_FLAG]
    return unless evaluation && evaluation[:source] == 'flagsmith' && evaluation[:enabled]

    Current.experiment = FLAGSMITH_SAMPLE_EXPERIMENT
  end

  def flagsmith_interactive_search_opted_in?
    Current.flagsmith_preferences&.[](INTERACTIVE_SEARCH_FLAG) == true
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
