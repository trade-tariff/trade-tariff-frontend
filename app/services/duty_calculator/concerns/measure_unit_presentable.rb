module MeasureUnitPresentable
  extend ActiveSupport::Concern

  def presented_unit
    @presented_unit ||= presented_unit_for(applicable_unit)
  end

  def applicable_unit
    applicable_units[component.unit]
  end

  def coerced_answer_for(unit)
    presented_unit = presented_unit_for(unit)

    presented_unit[:answer].to_f * presented_unit[:multiplier].to_f
  end

  def presented_unit_for(unit)
    {
      answer: unit_answer_for(unit),
      unit: unit['unit'],
      original_unit: unit['original_unit'],
      multiplier: unit['multiplier'].presence || 1,
    }
  end

  def unit_answer_for(unit)
    key = unit['coerced_measurement_unit_code'].presence || "#{unit['measurement_unit_code']}#{unit['measurement_unit_qualifier_code']}"

    user_session.measure_amount_for(key)
  end

  private

  def applicable_units
    @applicable_units ||= ApplicableMeasureUnitMerger.new(dedupe: false).call
  end
end
