require 'api_entity'

class CertificateType
  include ApiEntity

  attr_accessor :certificate_type_code, :description
end
