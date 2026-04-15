class CodeSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string
  attribute :description, :string

  validate :validate_code
  validate :validate_description

  def initialize(attributes = {})
    super
    sanitize_code!
  end

  def type
    code.to_s[0, self.class.type_length]
  end

  def to_params
    {
      code: code.to_s[self.class.type_length..],
      type:,
      description:,
    }
  end

  private

  def validate_code
    if code.present?
      sanitize_code!

      errors.add(:code, :length) unless code.length == self.class.code_length
      errors.add(:code, :invalid_characters) unless code.match?(/\A[A-Z0-9]{#{self.class.code_length}}\z/)
      errors.add(:code, :wrong_type) unless type.in?(self.class.valid_types)
    elsif description.blank?
      errors.add(:code, :blank)
    end
  end

  def validate_description
    errors.add(:description, :blank) if description.blank? && code.blank?
  end

  def sanitize_code!
    return if code.nil?

    code.strip!
    code.upcase!
  end
end
