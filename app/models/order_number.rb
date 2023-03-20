require 'api_entity'
require 'order_number/definition'

class OrderNumber
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
    definition.description
  end

  def show_warning?
    definition.description && number.start_with?('05')
  end

  def licenced?
    number[2] == '4'
  end
end
