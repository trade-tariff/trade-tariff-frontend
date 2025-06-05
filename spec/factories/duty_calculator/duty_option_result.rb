FactoryBot.define do
  factory :duty_calculator_duty_option_result, class: 'DutyCalculator::DutyOptionResult' do
    transient do
      measure_type_id { '103' }
    end

    type { DutyCalculator::DutyOptions::ThirdCountryTariff.id }
    category { DutyCalculator::DutyOptions::ThirdCountryTariff::CATEGORY }
    footnote { I18n.t("measure_type_footnotes.#{measure_type_id}") }
    measure_sid { generate(:measure_sid) }
    warning_text {}
    values { [] }
    value { 100 }
    source { 'uk' }

    initialize_with do
      DutyCalculator::DutyOptionResult.new(
        attributes.slice(
          :type,
          :footnote,
          :measure_sid,
          :source,
          :value,
          :values,
          :warning_text,
          :category,
          :priority,
          :scheme_code,
        ),
      )
    end
  end

  trait :third_country_tariff do
    type { DutyCalculator::DutyOptions::ThirdCountryTariff.id }
    category { DutyCalculator::DutyOptions::ThirdCountryTariff::CATEGORY }
    priority { DutyCalculator::DutyOptions::ThirdCountryTariff::PRIORITY }
    measure_type_id { '103' }
  end

  trait :tariff_preference do
    type { DutyCalculator::DutyOptions::TariffPreference.id }
    category { DutyCalculator::DutyOptions::TariffPreference::CATEGORY }
    measure_type_id { '142' }
    priority { DutyCalculator::DutyOptions::TariffPreference::PRIORITY }
    scheme_code { 'eu' }
  end

  trait :preferential_quota do
    type { DutyCalculator::DutyOptions::Quota::Preferential.id }
    category { DutyCalculator::DutyOptions::Quota::Base::CATEGORY }
    measure_type_id { '143' }
    priority { DutyCalculator::DutyOptions::Quota::Base::PRIORITY }
    scheme_code { 'albania' }
  end

  trait :preferential_quota_end_use do
    type { DutyCalculator::DutyOptions::Quota::PreferentialEndUse.id }
    category { DutyCalculator::DutyOptions::Quota::Base::CATEGORY }
    measure_type_id { '146' }
    priority { DutyCalculator::DutyOptions::Quota::Base::PRIORITY }
    scheme_code { 'andean' }
  end

  trait :suspension do
    type { DutyCalculator::DutyOptions::Suspension::Autonomous.id }
    category { DutyCalculator::DutyOptions::Suspension::Base::CATEGORY }
    measure_type_id { '112' }
    priority { DutyCalculator::DutyOptions::Suspension::Base::PRIORITY }
  end

  trait :quota do
    type { DutyCalculator::DutyOptions::Quota::NonPreferential.id }
    category { DutyCalculator::DutyOptions::Quota::Base::CATEGORY }
    measure_type_id { '122' }
    priority { DutyCalculator::DutyOptions::Quota::Base::PRIORITY }
    source { 'uk' }
  end

  trait :additional_duty do
    type { DutyCalculator::DutyOptions::AdditionalDuty::Excise.id }
    category { DutyCalculator::DutyOptions::AdditionalDuty::Excise::CATEGORY }
    measure_type_id { '306' }
    priority { DutyCalculator::DutyOptions::AdditionalDuty::Excise::PRIORITY }

    value { 300.0 }
    values do
      row_description = I18n.t(
        'duty_calculations.options.excise_duty_html',
        additional_code_description: '990 - Climate Change Levy (Tax code 990): solid fuels (coal and lignite, coke and semi-coke of coal or lignite, and petroleum coke)',
      )

      [row_description, '25.00% * £1,200.00', '£300.00']
    end
    source { 'uk' }
  end

  trait :unhandled do
    type { :unhandled }
    category { :unhandled }
    measure_type_id { 'flibble' }
    priority { -500 }
  end

  trait :uk do
    source { 'uk' }
  end

  trait :xi do
    source { 'xi' }
  end
end
