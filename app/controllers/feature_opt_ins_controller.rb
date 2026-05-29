class FeatureOptInsController < ApplicationController
  MANAGEABLE_FEATURES = %i[].freeze

  def create
    flag = params[:feature].to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    Flipper.enable_actor(flag, current_flipper_actor)
    redirect_back fallback_location: root_path
  end

  def destroy
    flag = params[:id].to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    Flipper.disable_actor(flag, current_flipper_actor)
    redirect_back fallback_location: root_path
  end
end
