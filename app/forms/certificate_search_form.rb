class CertificateSearchForm
  OPTIONAL_PARAMS = [:@page].freeze

  attr_accessor :code, :type, :description, :page

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def certificate_types
    TradeTariffFrontend::ServiceChooser.cache_with_service_choice(
      'cached_certificate_types', expires_in: 24.hours
    ) do
      CertificateType.all&.sort_by(&:certificate_type_code).map do |type|
        [ "#{type&.certificate_type_code} - #{type&.description}", type&.certificate_type_code ]
      end.to_h
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
end
