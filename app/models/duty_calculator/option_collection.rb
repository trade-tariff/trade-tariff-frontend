class OptionCollection < SimpleDelegator
  WRAPPED_METHODS = %i[
    reject
    select
    sort_by
    uniq
  ].freeze

  def initialize(options)
    super

    @options = options
  end

  WRAPPED_METHODS.each do |method|
    define_method(method) do |&block|
      self.class.new(super(&block))
    end
  end

  def tariff_preference_options
    @tariff_preference_options ||= select { |option| option.category == DutyOptions::TariffPreference::CATEGORY }
  end

  def suspension_options
    @suspension_options ||= select { |option| option.category == DutyOptions::Suspension::Base::CATEGORY }
  end

  def quota_options
    @quota_options ||= select { |option| option.category == DutyOptions::Quota::Base::CATEGORY }
  end

  def third_country_tariff_options
    @third_country_tariff_options ||= select { |option| option.category == DutyOptions::ThirdCountryTariff::CATEGORY }
  end

  def cheapest_tariff_preference_option
    @cheapest_tariff_preference_option ||= tariff_preference_options.min_by(&:value)
  end

  def cheapest_suspension_option
    @cheapest_suspension_option ||= suspension_options.min_by(&:value)
  end

  def cheapest_quota_option
    @cheapest_quota_option ||= quota_options.min_by(&:value)
  end

  def third_country_tariff_option
    @third_country_tariff_option ||= find { |option| option.type == DutyOptions::ThirdCountryTariff.id }
  end
end
