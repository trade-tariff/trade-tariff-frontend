module MeasuresHelper
  def order_number_info(record)
    record.definition.try(:description) || "Order number #{record.number}"
  end

  def filter_duty_expression(measure)
    record = measure.duty_expression.to_s.html_safe
    record = '' if record == 'NIHIL'
    record = 'see conditions' if measure.measure_type.id.in? %w(DDA DDJ)
    record
  end
end
