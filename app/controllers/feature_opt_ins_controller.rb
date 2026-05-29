class FeatureOptInsController < ApplicationController
  MANAGEABLE_FEATURES = %i[].freeze

  def create
    flag = params[:feature].to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    Flipper.enable_actor(flag, current_flipper_actor)
    redirect_to_return_or_back
  end

  def destroy
    flag = params[:id].to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    Flipper.disable_actor(flag, current_flipper_actor)
    redirect_to_return_or_back
  end

  private

  # Redirect to the explicit return_to path if it is a safe local path,
  # otherwise fall back to the Referer header or root.
  def redirect_to_return_or_back
    path = params[:return_to].to_s
    if local_path?(path)
      redirect_to path
    else
      redirect_back fallback_location: root_path
    end
  end

  # A safe local path starts with / but not // (protocol-relative URLs such as
  # //evil.com would redirect off-site and must be rejected).
  def local_path?(path)
    path.start_with?('/') && !path.start_with?('//')
  end
end
