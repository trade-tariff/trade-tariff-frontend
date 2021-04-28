require 'api_entity'

class MeasureCondition
  include ApiEntity

  attr_accessor :condition_code, :condition, :document_code, :action, :duty_expression
  attr_writer :requirement

  def requirement
    @requirement&.html_safe
  end
end
