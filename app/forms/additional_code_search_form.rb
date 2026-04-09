class AdditionalCodeSearchForm < CodeSearchForm
  OPTIONAL_PARAMS = [:@page].freeze
  EXCLUDED_TYPES = %w[6 7 9 D F P].freeze

  attr_writer :page

  def type
    code.to_s[0]
  end

  class << self
    def code_length = 4
    def type_length = 1
    def valid_types = possible_types

    def possible_types
      additional_code_type_ids.reject { |id| EXCLUDED_TYPES.include?(id) }
    end

    private

    def additional_code_type_ids
      @additional_code_type_ids ||= AdditionalCodeType.all.map(&:additional_code_type_id).sort
    end
  end
end
