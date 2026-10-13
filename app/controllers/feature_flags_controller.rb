class FeatureFlagsController < ApplicationController
  before_action :require_management_client
  before_action :disable_search_form

  def index
    if @flagsmith_preferences_unavailable
      @optin_features = []
      flash.now[:alert] = 'Feature flags could not be loaded. Your saved preferences have not been changed.'
      return
    end

    @optin_features = optin_features
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#index: Flagsmith unavailable: #{e.class}: #{e.message}")
    @flagsmith_preferences_unavailable = true
    @optin_features = []
    flash.now[:alert] = 'Feature flags could not be loaded. Flagsmith may be unavailable.'
  end

  def update
    flag_name = params[:id]

    unless optin_flag_names.include?(flag_name)
      return redirect_to feature_flags_path, alert: 'That feature is not available for opt-in.'
    end

    enabled = params[:enabled] == 'true'

    FlagsmithManagementClient.instance.set_trait(
      Current.flagsmith_identity.identifier,
      flag_name,
      enabled,
    )

    @flagsmith_preferences.write(@flagsmith_preferences.read.merge(flag_name => enabled))

    redirect_to feature_flags_path, notice: "#{flag_name.humanize} #{enabled ? 'enabled' : 'disabled'}."
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#update: failed to set trait #{params[:id]}: #{e.class}: #{e.message}")
    redirect_to feature_flags_path, alert: 'Could not save your preference. Flagsmith may be unavailable.'
  end

  private

  # Refresh before set_path_info first evaluates flags, so the page and its
  # navigation use the same preferences. Other pages never read core.
  def load_flagsmith_preferences
    cached = super
    return cached unless action_name == 'index' && FlagsmithManagementClient.configured?

    @flagsmith_preferences.write(FlagsmithManagementClient.instance.get_traits_for(Current.flagsmith_identity))
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#index: preference refresh failed: #{e.class}: #{e.message}")
    @flagsmith_preferences_unavailable = true
    cached || {}
  end

  def require_management_client
    render plain: 'Not found', status: :not_found unless FlagsmithManagementClient.configured?
  end

  def optin_flag_names
    optin_features.pluck(:name)
  end

  def optin_features
    TradeTariffFrontend::Config.registered_flags.filter_map { |method_name, flag|
      next unless flag[:optin]
      next unless flag[:services].empty? || flag[:services].include?(TradeTariffFrontend::ServiceChooser.service_name)

      name = flag[:name]
      enabled = TradeTariffFrontend.public_send(method_name)
      next if !enabled && Current.flagsmith_evaluations.dig(name, :source) == 'environment'

      { name:, enabled: }
    }.sort_by { |feature| feature[:name] }
  end
end
