class QuotaSearchForm
  CRITICAL_VALUES = { 'Yes' => 'Y', 'No' => 'N' }.freeze
  STATUS_VALUES = [%w[Blocked blocked],
                   %w[Exhausted exhausted],
                   ['Not blocked', 'not_blocked'],
                   ['Not exhausted', 'not_exhausted']].freeze
  DEFAULT_YEAR_VALUE = Date.current.year.to_s.freeze
  DEFAULT_MONTH_VALUE = Date.current.month.to_s.freeze
  DEFAULT_DAY_VALUE = Date.current.day.to_s.freeze
  OPTIONAL_PARAMS = %i[@year @month @day @page].freeze

  attr_accessor :goods_nomenclature_item_id, :geographical_area_id, :order_number,
                :critical, :status, :day, :month, :year
  attr_writer   :page

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def page
    @page || 1
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def blank?
    (instance_variables - OPTIONAL_PARAMS).blank?
  end

  def large_result?
    blank? && instance_variables.present?
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
      day: day,
      month: month,
      year: year,
      page: page,
    }
  end
end
