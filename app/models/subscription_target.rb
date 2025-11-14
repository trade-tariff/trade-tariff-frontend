class SubscriptionTarget
  include ApiEntity

  attr_accessor :target_type,
                :chapter_short_code,
                :goods_nomenclature_item_id,
                :hierarchical_description,
                :meta

  def self.all(token, target, page: 1, per_page: 10)
    return nil if token.nil? && !Rails.env.development?

    path = "/uk/user/subscription_targets/#{token}?filter[active_commodities_type]=#{target}&page=#{page}&per_page=#{per_page}"
    collection(path, {}, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.headers(token)
    {
      authorization: "Bearer #{token}",
    }
  end
end
