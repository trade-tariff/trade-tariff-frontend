FactoryBot.define do
  sequence(:measure_condition_sid, &:to_s)

  factory :duty_calculator_measure_condition, class: 'DutyCalculator::Api::MeasureCondition' do
    id { generate(:measure_condition_sid) }
    action {}
    action_code {}
    certificate_description {}
    condition {}
    condition_code {}
    condition_duty_amount {}
    condition_measurement_unit_code {}
    condition_measurement_unit_qualifier_code {}
    condition_monetary_unit_code {}
    document_code {}
    duty_expression { "<span>35.10</span> GBP / <abbr title='Hectokilogram'>100 kg</abbr>" }
    monetary_unit_abbreviation {}
    requirement {}
    measure_condition_components { [] }

    trait :with_measure_units do
      condition_duty_amount { 35.1 }
      condition_measurement_unit_code { 'DTN' }
      duty_expression { "<span>35.10</span> GBP / <abbr title='Hectokilogram'>100 kg</abbr>" }

      measure_condition_components do
        [
          attributes_for(
            :duty_calculator_measure_condition_component,
            :with_measure_units,
            measure_condition_sid: id,
          ),
        ]
      end
    end

    trait :spq_positive do
      action { 'Apply the amount of the action (see components)' }
      action_code { '01' }
      certificate_description {}
      condition { 'E: The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document' }
      condition_code { 'E' }
      condition_duty_amount { 3.49 }
      condition_measurement_unit_code { 'ASV' }
      condition_measurement_unit_qualifier_code {}
      condition_monetary_unit_code {}
      document_code { '' }
      duty_expression { "<span>9.27</span> GBP / <abbr title='Litre pure (100%) alcohol'>l alc. 100%</abbr> - £1.00  / for each litre of pure alcohol, multiplied by the SPR discount" }
      measure_condition_class { 'threshold' }
      monetary_unit_abbreviation {}
      requirement { "<span>3.49</span> <abbr title='%vol'>% vol</abbr>" }
      requirement_operator { '=<' }
      threshold_unit_type { 'percentage_abv' }
    end

    trait :stopping_negative do
      action { 'Declared subheading not allowed' }
      action_code { '08' }
      certificate_description {}
      condition { 'B: Presentation of a certificate/licence/document' }
      condition_code { 'B' }
      condition_duty_amount {}
      condition_measurement_unit_code {}
      condition_measurement_unit_qualifier_code {}
      condition_monetary_unit_code {}
      document_code { '' }
      duty_expression { '' }
      monetary_unit_abbreviation {}
      requirement {}
      measure_condition_class { 'negative' }
    end

    trait :stopping_document do
      action { 'Apply the mentioned duty' }
      action_code { '27' }
      certificate_description { 'EUS - Authorisation for the use of end use procedure (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' }
      condition { 'B: Presentation of a certificate/licence/document' }
      condition_code { 'B' }
      condition_duty_amount {}
      condition_measurement_unit_code {}
      condition_measurement_unit_qualifier_code {}
      condition_monetary_unit_code {}
      document_code { 'N990' }
      duty_expression { '' }
      monetary_unit_abbreviation {}
      requirement { 'UN/EDIFACT certificates: EUS - Authorisation for the use of end use procedure (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)' }
      measure_condition_class { 'document' }
    end

    trait :declaration_document_present do
      action { 'Declared subheading allowed' }
      action_code { '28' }
      condition { 'B: Presentation of a certificate/licence/document' }
      condition_code { 'B' }
      document_code { 'D019' }

      certificate_description do
        'Authorisation to use a customs procedure with economic impact/end-use within the context of an anti-dumping/countervailing measure (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)'
      end

      requirement do
        'Anti-dumping/countervailing document: Authorisation to use a customs procedure with economic impact/end-use within the context of an anti-dumping/countervailing measure (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)'
      end
    end

    trait :declaration_document_not_present do
      action { 'Declared subheading not allowed' }
      action_code { '08' }
      condition { 'B: Presentation of a certificate/licence/document' }
      condition_code { 'B' }
    end
  end
end
