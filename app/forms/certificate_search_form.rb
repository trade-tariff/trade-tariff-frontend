class CertificateSearchForm < CodeSearchForm
  def type
    code.to_s[0]
  end

  class << self
    def code_length = 4
    def type_length = 1
    def valid_types = certificate_types

    def certificate_types
      @certificate_types ||= CertificateType.all.map(&:certificate_type_code).sort
    end
  end
end
