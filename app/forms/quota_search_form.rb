class QuotaSearchForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  CRITICAL_VALUES = { 'Yes' => 'Y', 'No' => 'N' }.freeze
  STATUS_VALUES = [%w[Blocked blocked],
                   %w[Exhausted exhausted],
                   ['Not blocked', 'not_blocked'],
                   ['Not exhausted', 'not_exhausted']].freeze
  OPTIONAL_PARAMS = %i[@year @month @day @page @errors].freeze

  PERMITTED_PARAMS = %i[order_number
                        goods_nomenclature_item_id
                        geographical_area_id
                        day
                        month
                        year
                        critical
                        status
                        page].freeze

  attr_accessor :goods_nomenclature_item_id, :geographical_area_id, :order_number,
                :critical, :status
  attr_writer   :page, :day, :month, :year

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end

    validate_invalid_date! if date_input_provided?
  end

  def page
    @page || 1
  end

  def year
    @year || default_year_value
  end

  def month
    @month || default_month_value
  end

  def day
    @day || default_day_value
  end

  def present?
    return false if errors.any?

    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def blank?
    (instance_variables - OPTIONAL_PARAMS).blank?
  end

  def large_result?
    blank? && date_input_provided?
  end

  def geographical_areas
    GeographicalArea.all
  end

  def as_of
    {
      1 => year,
      2 => month,
      3 => day,
    }
  end

  def date
    TariffDate.build(year:, month:, day:)
  rescue Date::Error
    raise Search::InvalidDate
  end

  def validate_invalid_date!
    date
  rescue Search::InvalidDate
    errors.add(:as_of, 'You must enter a valid date')
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def to_params
    {
      goods_nomenclature_item_id:,
      geographical_area_id:,
      order_number:,
      critical:,
      status:,
      day: day,
      month: month,
      year: year,
      page:,
    }
  end

  def persisted?
    false
  end

  def read_attribute_for_validation(attribute)
    public_send(attribute)
  end

  private

  def date_input_provided?
    [@day, @month, @year].any?(&:present?)
  end

  def default_year_value
    Date.current.year.to_s
  end

  def default_month_value
    Date.current.month.to_s
  end

  def default_day_value
    Date.current.day.to_s
  end
end
