class FeatureFlagsController < ApplicationController
  before_action :require_management_client

  def index
    flags = Current.flagsmith_flags ||= FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)

    @optin_features = flags.all_flags
      .select { |f| f.feature_name.end_with?('_optin') && f.enabled? }
      .map { |optin_flag|
        feature_name = optin_flag.feature_name.delete_suffix('_optin')
        { name: feature_name, enabled: flags.get_flag(feature_name).enabled? }
      }
      .sort_by { |f| f[:name] }
  rescue StandardError => e
    Rails.logger.error("FeatureFlagsController#index: Flagsmith unavailable: #{e.class}: #{e.message}")
    @optin_features = []
    flash.now[:alert] = 'Feature flags could not be loaded. Flagsmith may be unavailable.'
  end

  def update
    flag_name = params[:id]
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
end
