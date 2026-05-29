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
    safe = safe_local_path(params[:return_to].to_s)
    if safe
      redirect_to safe, allow_other_host: false
    else
      redirect_back fallback_location: root_path
    end
  end

  # Parse return_to with URI.parse and return only the path+query when the URI
  # has no host component and the path starts with /. This definitively excludes
  # absolute URLs (http://evil.com), protocol-relative URLs (//evil.com), and
  # non-HTTP schemes (javascript:) regardless of string prefix tricks.
  # allow_other_host: false at the call site adds a second layer via Rails.
  def safe_local_path(raw)
    uri = URI.parse(raw)
    return nil unless uri.host.blank? && uri.path.to_s.start_with?('/')

    uri.query ? "#{uri.path}?#{uri.query}" : uri.path
  rescue URI::InvalidURIError
    nil
  end
end
