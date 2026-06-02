class FeatureOptInsController < ApplicationController
  # Flags that users are allowed to opt in/out of via the UI.
  # Add flag names here when a beta opt-in flow is introduced.
  MANAGEABLE_FEATURES = %i[].freeze

  def create
    flag = params[:feature].to_s.to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    FlagsmithClient.instance.enable_for_identity(flag, Current.flagsmith_identity)
    redirect_to_return_or_back
  end

  def destroy
    flag = params[:id].to_s.to_sym
    return head :forbidden unless MANAGEABLE_FEATURES.include?(flag)

    FlagsmithClient.instance.disable_for_identity(flag, Current.flagsmith_identity)
    redirect_to_return_or_back
  end

  private

  # Redirect to the explicit return_to path if it is a safe local path,
  # otherwise fall back to the Referer header or root.
  def redirect_to_return_or_back
    safe = safe_local_path(params[:return_to].to_s)
    if safe
      redirect_to safe, allow_other_host: false
    else
      redirect_back fallback_location: root_path
    end
  end

  # Returns only the path+query when return_to has no host component and
  # starts with /. Rejects absolute URLs, protocol-relative URLs, and
  # non-HTTP schemes regardless of string prefix tricks.
  def safe_local_path(raw)
    uri = URI.parse(raw)
    return nil unless uri.host.blank? && uri.path.to_s.start_with?('/')

    uri.query ? "#{uri.path}?#{uri.query}" : uri.path
  rescue URI::InvalidURIError
    nil
  end
end
