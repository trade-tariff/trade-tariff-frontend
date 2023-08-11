class CertificateSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string
  attribute :description, :string

  validate :validate_code
  validate :validate_description

  def validate_code
    if code.present?
      code.strip!

      errors.add(:code, :invalid) unless code =~ /\A([A-Z]|[0-9]){4}\z/
      errors.add(:code, :wrong_type) unless type.in?(self.class.certificate_types)
    elsif description.blank?
      errors.add(:code, :blank)
    end
  end

  def validate_description
    errors.add(:description, :blank) if description.blank? && code.blank?
  end

  def type
    code.to_s[0]
  end

  def to_params
    {
      code: code.to_s[1..],
      type:,
      description:,
    }
  end

  class << self
    def certificate_types
      @certificate_types ||= CertificateType.all.map(&:certificate_type_code).sort
    end
  end
end
