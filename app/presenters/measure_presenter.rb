class MeasurePresenter
  attr_reader :measure

  def initialize(measure)
    @measure = measure
  end

  def geo_class
    measure.geographical_area.id || measure.geographical_area.children_geographical_areas.sort_by(&:id).map(&:id).join(' ')
  end

  def has_children_geographical_areas?
    measure.geographical_area.children_geographical_areas.any?
  end

  def children_geographical_areas
    measure.geographical_area.children_geographical_areas.sort_by(&:id)
  end

  def has_measure_conditions?
    measure.measure_conditions.any?
  end

  def grouped_measure_conditions
    measure.measure_conditions.group_by do |condition|
      {
        condition: condition.condition,
        partial_type: case condition.condition_code
                      when 'A', 'B', 'C', 'H', 'Q', 'Y', 'Z'
                        'document'
                      when 'R', 'S', 'U'
                        'ratio'
                      when 'F', 'L', 'M', 'V'
                        'ratio_duty'
                      when 'E', 'I'
                        'quantity'
                      else
                        'default'
                      end
      }
    end
  end

  def has_references?
    measure.measure_conditions.any? || measure.footnotes.any?
  end

  def has_measure_footnotes?
    measure.footnotes.any?
  end

  def has_additional_code?
    additional_code.present?
  end

  private

  def method_missing(*args, &block)
    @measure.send(*args, &block)
  end
end
