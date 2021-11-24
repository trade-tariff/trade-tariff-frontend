class CertificateType
  include ApiEntity

  collection_path '/certificate_types'

  attr_accessor :certificate_type_code, :description
end
