class MeasureComponent
  include ApiEntity

  has_one :duty_expression
  has_one :measurement_unit
  has_one :measurement_unit_qualifier

  def unit_for_classification
    "#{measurement_unit&.description} (#{casted_by.duty_expression&.base})"
  end
end
