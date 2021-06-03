module MeasuresHelper
  def filter_duty_expression(measure)
    duty_expression = measure.duty_expression.to_s.html_safe
    duty_expression = '' if duty_expression == 'NIHIL'
    duty_expression = 'see conditions' if measure.measure_type.id.in? %w[DDA DDJ]
    duty_expression
  end
end
