class SubscriptionTarget
  include AuthenticatableApiEntity

  attr_accessor :target_type,
                :chapter_short_code,
                :goods_nomenclature_item_id,
                :hierarchical_description,
                :meta

  def self.all(token, params)
    return nil if token.nil? && !Rails.env.development?

    set_collection_path "/uk/user/subscription_targets/#{token}"
    super(params)
  rescue Faraday::UnauthorizedError
    nil
  end
end
