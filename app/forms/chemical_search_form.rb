class ChemicalSearchForm
  OPTIONAL_PARAMS = [:@page].freeze

  attr_accessor :cas, :name

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def page
    @page ||= 1
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def to_params
    {
      cas:,
      name:,
      page:,
    }
  end
end
