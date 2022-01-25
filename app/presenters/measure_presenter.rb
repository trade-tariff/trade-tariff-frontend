class MeasurePresenter < SimpleDelegator
  def has_children_geographical_areas?
    geographical_area.children_geographical_areas.any?
  end

  def has_measure_conditions?
    measure_conditions.any?
  end

  def has_additional_code?
    additional_code.present?
  end

  def has_measure_footnotes?
    footnotes.any?
  end

  def children_geographical_areas
    geographical_area.children_geographical_areas.sort_by(&:id)
  end

  def grouped_measure_conditions
    measure_conditions.group_by do |condition|
      {
        condition: condition.condition,
        partial_type: case condition.condition_code[0]
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
                      end,
      }
    end
  end
end
