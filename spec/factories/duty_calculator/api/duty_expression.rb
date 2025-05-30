FactoryBot.define do
  sequence(:duty_expression_id) { |id| "#{id}-duty-expression" }

  factory :duty_calculator_duty_expression, class: 'DutyCalculator::Api::DutyExpression' do
    id { generate(:duty_expression_id) }
    base { '144.10 GBP / 1000 kg/biodiesel' }
    formatted_base { "<span>144.10</span> GBP / <abbr title='Tonne'>1000 kg/biodiesel</abbr>" }

    trait :alcohol_volume_measure_unit do
      base { '0.50 GBP / % vol/hl + 2.60 GBP / hl' }
      formatted_base do
        "<span>0.50</span> GBP / <abbr title='%vol'>% vol/hl</abbr> + <span>2.60</span> GBP / <abbr title='Hectolitre'>hl</abbr>"
      end
    end

    trait :sucrose_measure_unit do
      base { '0.30 GBP / 100 kg/net/%sacchar.' }
      formatted_base { "<span>0.30</span> GBP / <abbr title='Hectokilogram'>100 kg/net/%sacchar.</abbr>" }
    end

    trait :euro_measure_unit do
      base { '35.10 EUR / 100 kg' }
      formatted_base { "<span>35.10</span> EUR / <abbr title='Hectokilogram'>100 kg</abbr>" }
    end

    trait :pounds_measure_unit do
      base { '35.10 GBP / 100 kg' }
      formatted_base { "<span>35.10</span> GBP / <abbr title='Hectokilogram'>100 kg</abbr>" }
    end
  end
end
