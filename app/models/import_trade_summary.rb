require 'api_entity'

class ImportTradeSummary
  include ApiEntity

  attr_accessor :basic_third_country_duty,
                :preferential_tariff_duty,
                :preferential_quota_duty

  def preferential_duties?
    preferential_tariff_duty.present? || preferential_quota_duty.present?
  end

  def no_preferential_duties?
    !preferential_duties?
  end
end
