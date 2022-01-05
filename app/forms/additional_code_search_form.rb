class AdditionalCodeSearchForm
  OPTIONAL_PARAMS = [:@page].freeze
  EXCLUDED_TYPES = %w[6 7 9 D F P].freeze

  attr_accessor :code, :type, :description
  attr_writer :page

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def additional_code_types
    TradeTariffFrontend::ServiceChooser.cache_with_service_choice('cached_additional_code_types-v2', expires_in: 24.hours) do
      AdditionalCodeType.all
                        &.sort_by(&:additional_code_type_id)
                        &.reject(&method(:exclude_additional_code_type?))
                        &.map(&method(:additional_code_type_option))
                        &.to_h
    end
  end

  def page
    @page || 1
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def to_params
    {
      code: code,
      type: type,
      description: description,
      page: page,
    }
  end

private

  def additional_code_type_option(type)
    ["#{type&.additional_code_type_id} - #{type&.description}", type&.additional_code_type_id]
  end

  def exclude_additional_code_type?(type)
    EXCLUDED_TYPES.include? type.additional_code_type_id
  end
end
