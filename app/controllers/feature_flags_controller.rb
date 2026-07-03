class FeatureFlagsController < ApplicationController
  before_action :require_management_client
  before_action :disable_search_form

  def index
    flags = FlagsmithManagementClient.instance.get_flags_for(Current.flagsmith_identity)

    @optin_features = optin_flag_names.map { |name|
      { name: name, enabled: flags.get_flag(name).enabled? }
    }.sort_by { |f| f[:name] }
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#index: Flagsmith unavailable: #{e.class}: #{e.message}")
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

    redirect_to feature_flags_path, notice: "#{flag_name} #{enabled ? 'enabled' : 'disabled'}."
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#update: failed to set trait #{params[:id]}: #{e.class}: #{e.message}")
    redirect_to feature_flags_path, alert: 'Could not save your preference. Flagsmith may be unavailable.'
  end

  private

  def require_management_client
    render plain: 'Not found', status: :not_found unless FlagsmithManagementClient.configured?
  end

  def optin_flag_names
    TradeTariffFrontend::Config.registered_flags
      .values
      .select { |f| f[:optin] }
      .map { |f| f[:name] }
  end
end
