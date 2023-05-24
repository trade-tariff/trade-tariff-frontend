FactoryBot.define do
  factory :measure_component do
    trait :with_supplementary_measurement_unit do
      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end

      measurement_unit do
        attributes_for(:measurement_unit, :supplementary)
      end
    end

    trait :with_monetary_unit_measure_components do
      duty_expression do
        attributes_for(:duty_expression, base: 'EUR')
      end
    end

    trait :with_measurement_unit_measure_components do
      duty_expression do
        attributes_for(
          :duty_expression,
          base: '95.10 GBP / 100 kg',
          formatted_base: '<span>95.10</span> GBP / <abbr title="Hectokilogram">100 kg</abbr>',
          verbose_duty: '£95.10 / 100 kg',
        )
      end

      measurement_unit do
        attributes_for(:measurement_unit, :hectokilogram)
      end
    end
  end
end
