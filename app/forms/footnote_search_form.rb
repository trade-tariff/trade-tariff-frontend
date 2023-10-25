class FootnoteSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string
  attribute :description, :string

  validate :validate_code
  validate :validate_description

  def validate_code
    if code.present?
      sanitize_code!

      errors.add(:code, :length) unless code.length == 5
      errors.add(:code, :invalid_characters) unless code =~ /\A([A-Z]|[0-9]){5}\z/
      errors.add(:code, :wrong_type) unless type.in?(self.class.footnote_types)
    elsif description.blank?
      errors.add(:code, :blank)
    end
  end

  def validate_description
    errors.add(:description, :blank) if description.blank? && code.blank?
  end

  def type
    code.to_s[0..1]
  end

  def id
    code.to_s[2..]
  end

  def to_params
    {
      code: id,
      type:,
      description:,
    }
  end

  private

  def sanitize_code!
    code.strip!
    code.upcase!
  end

  class << self
    def footnote_types
      @footnote_types ||= FootnoteType.all.map(&:footnote_type_id).sort
    end
  end
end
