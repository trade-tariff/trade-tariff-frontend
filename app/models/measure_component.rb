class MeasureComponent
  include ApiEntity

  has_one :duty_expression
  has_one :measurement_unit
end
