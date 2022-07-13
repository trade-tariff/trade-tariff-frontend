require 'api_entity'
require 'order_number/definition'

class OrderNumber
  ORDER_NUMBERS_WITH_KNOWN_ISSUES = %w[
    052012
    052105
    052106
  ].freeze

  include ApiEntity

  attr_accessor :number

  delegate :present?, to: :number

  has_one :definition, class_name: 'OrderNumber::Definition'
  has_one :geographical_area
  has_many :geographical_areas

  def id
    @id ||= "#{casted_by.id}-order-number-#{number}"
  end

  def definition
    return @definition if @definition
    return casted_by if casted_by.is_a?(OrderNumber::Definition)
  end

  def warning_text
    if known_data_issues?
      I18n.t('quota_definition.order_number.known_issues')
    else
      definition.description
    end
  end

  def show_warning?
    starts_with_05? || known_data_issues?
  end

  private

  def starts_with_05?
    definition.description && number.start_with?('05')
  end

  # TODO: Remove me. QAM has issues with loading quotas with a hierarchy at the moment and is decrement quotas too quickly
  def known_data_issues?
    number.in?(ORDER_NUMBERS_WITH_KNOWN_ISSUES)
  end
end
