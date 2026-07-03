module FlagsmithSetup
  extend ActiveSupport::Concern

  private

  def set_current_flagsmith_identity
    Current.flagsmith_identity = current_flagsmith_identity
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
