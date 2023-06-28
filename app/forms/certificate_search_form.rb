class CertificateSearchForm
  OPTIONAL_PARAMS = [:@page].freeze

  attr_accessor :code, :type, :description

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def certificate_types
    CertificateType.all.sort_by(&:certificate_type_code).map { |type|
      ["#{type&.certificate_type_code} - #{type&.description}", type&.certificate_type_code]
    }.to_h
  end

  def page
    @page || 1
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def to_params
    {
      code:,
      type:,
      description:,
      page:,
    }
  end
end
