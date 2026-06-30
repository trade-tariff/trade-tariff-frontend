module QuotaSearchHelper
  def quota_search_today_params(order_number)
    all_quota_search_params(order_number).to_h.each_with_object({}) do |(key, value), params|
      next if value.blank?

      params[key] = h(value)
    end
  end

  def quota_search_date_params
    extract_search_date_parts(params[:quota_search_form].presence || params)
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
    params.permit(QuotaSearchForm::PERMITTED_PARAMS).to_h.merge(quota_search_date_params).compact
  end
end
