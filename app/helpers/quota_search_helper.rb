module QuotaSearchHelper
  def quota_search_today_params(order_number)
    all_quota_search_params(order_number).to_h.each_with_object({}) do |(key, value), params|
      next if value.blank?

      params[key] = h(value)
    end
  end

  private

  def all_quota_search_params(order_number)
    quota_search_params.merge(
      day: Time.zone.today.day,
      month: Time.zone.today.month,
      year: Time.zone.today.year,
      anchor: "order-number-#{order_number.number}",
    )
  end

  def quota_search_params
    params.permit(QuotaSearchForm::PERMITTED_PARAMS)
  end
end
