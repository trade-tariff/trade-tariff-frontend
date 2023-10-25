class AdditionalCodeSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  OPTIONAL_PARAMS = [:@page].freeze
  EXCLUDED_TYPES = %w[6 7 9 D F P].freeze

  attribute :code, :string
  attribute :description, :string

  validate :validate_code
  validate :validate_description

  attr_writer :page

  def validate_code
    sanitize_code

    if code.present?
      errors.add(:code, :length) unless code.length == 4
      errors.add(:code, :wrong_type) unless type.in?(self.class.possible_types)
    elsif description.blank?
      errors.add(:code, :blank)
    end
  end

  def validate_description
    unless description.present? || code.present?
      errors.add(:description, :blank)
    end
  end

  def type
    code.to_s[0]
  end

  def to_params
    {
      code: code.to_s[1..],
      type: code.to_s[0],
      description:,
    }
  end

  class << self
    def possible_types
      additional_code_type_ids
        .reject do |additional_code_type_id|
          EXCLUDED_TYPES.include?(additional_code_type_id)
        end
    end

    private

    def additional_code_type_ids
      @additional_code_type_ids ||= AdditionalCodeType.all.map(&:additional_code_type_id).sort
    end
  end

  private

  def sanitize_code
    return if code.blank?

    code.strip!
    code.upcase!
  end
end
