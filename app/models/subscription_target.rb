class SubscriptionTarget
  include AuthenticatableApiEntity

  attr_accessor :target_type, :target_object

  has_one :target_object, class_name: 'TariffChanges::Commodity'

  delegate :goods_nomenclature_item_id, :classification_description, :validity_end_date, to: :target_object

  def self.all(id, token, params)
    return nil if token.nil? && !Rails.env.development?

    path = "/uk/user/subscriptions/#{id}/targets"
    collection(path, params, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end
end
