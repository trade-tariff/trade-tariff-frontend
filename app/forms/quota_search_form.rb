class QuotaSearchForm
  CRITICAL_VALUES = { 'Yes' => 'Y', 'No' => 'N' }.freeze
  STATUS_VALUES = [['Blocked', 'blocked'],
                   ['Exhausted', 'exhausted'],
                   ['Not blocked', 'not_blocked'],
                   ['Not exhausted', 'not_exhausted']].freeze
  YEARS_VALUES = *(5.years.ago.year..Date.today.year).freeze
  DEFAULT_YEARS_VALUE = Date.current.year.to_s.freeze
  OPTIONAL_PARAMS = [:@years, :@page]

  attr_accessor :goods_nomenclature_item_id, :geographical_area_id, :order_number, :critical, :status, :years, :page

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def page
    @page || 1
  end

  def years
    Array.wrap(@years || DEFAULT_YEARS_VALUE)
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def large_result?
    !present? && instance_variables.present?
  end

  def geographical_area
    GeographicalArea.all.find do |country|
      country.id == geographical_area_id
    end
  end

  def to_params
    {
      goods_nomenclature_item_id: goods_nomenclature_item_id,
      geographical_area_id: geographical_area_id,
      order_number: order_number,
      critical: critical,
      status: status,
      years: years,
      page: page,
    }
  end
end
