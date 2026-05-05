class MeasurePresenter < SimpleDelegator
  DOCUMENT_CODE_EXCLUSIONS = %w[999L].freeze

  # Boolean memoization helper — ||= doesn't work for false values.
  # Each predicate is called from both _measure.html.erb (the table row)
  # and _measure_references.html.erb (the modal/footnote references panel),
  # so we cache the result to avoid re-evaluating the same check twice per
  # measure per request.
  def has_children_geographical_areas?
    return @has_children_geographical_areas if instance_variable_defined?(:@has_children_geographical_areas)

    @has_children_geographical_areas = geographical_area.children_geographical_areas.any?
  end

  def has_measure_conditions?
    return @has_measure_conditions if instance_variable_defined?(:@has_measure_conditions)

    @has_measure_conditions = measure_conditions.any?
  end

  def has_additional_code?
    return @has_additional_code if instance_variable_defined?(:@has_additional_code)

    @has_additional_code = additional_code.present?
  end

  def has_measure_footnotes?
    return @has_measure_footnotes if instance_variable_defined?(:@has_measure_footnotes)

    @has_measure_footnotes = footnotes.any?
  end

  def children_geographical_areas
    @children_geographical_areas ||= geographical_area.children_geographical_areas.sort_by(&:id)
  end

  def measure_conditions_without_exclusions
    @measure_conditions_without_exclusions ||= measure_conditions.reject do |condition|
      DOCUMENT_CODE_EXCLUSIONS.include?(condition.document_code)
    end
  end

  def grouped_measure_conditions
    @grouped_measure_conditions ||= measure_conditions_without_exclusions.group_by do |condition|
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

  def permutations_enabled?
    groups = measure_condition_permutation_groups
    groups.any? && groups.all? { |pg| pg.permutations.any? }
  end
end
