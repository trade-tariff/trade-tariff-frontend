require 'api_entity'

class AdditionalCode
  include ApiEntity

  PHARMA_CODES = %w[2500 2501].freeze
  RESIDUAL_CODES = %w[49 98 99].freeze

  has_many :goods_nomenclatures, polymorphic: true

  attr_accessor :additional_code_type_id,
                :additional_code,
                :code,
                :description,
                :formatted_description

  delegate :present?, to: :code, allow_nil: true

  def id
    @id ||= "#{casted_by.destination}-#{casted_by.id}-additional-code-#{code}"
  end

  def pharma?
    code.in?(PHARMA_CODES)
  end

  def residual?
    RESIDUAL_CODES.include? code.last(2)
  end
end
