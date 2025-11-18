class SubscriptionTarget
  include AuthenticatableApiEntity

  attr_accessor :target_type,
                :chapter_short_code,
                :goods_nomenclature_item_id,
                :hierarchical_description,
                :meta

  def self.all(id, token, params)
    return nil if token.nil? && !Rails.env.development?

    path = "/uk/user/subscription_targets/#{id}"
    collection(path, params, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end
end
