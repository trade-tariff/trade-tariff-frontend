Dir[File.join(__dir__, '../../app/models/duty_calculator/steps/', '*.rb')].sort.each { |file| require_relative file }

POSSIBLE_STEPS = DutyCalculator::Steps.constants.reject { |step| step =~ /Controller$/ }
POSSIBLE_ANSWERS = POSSIBLE_STEPS.map { |step| "DutyCalculator::Steps::#{step}".constantize.id }

FactoryBot.define do
  factory :duty_calculator_user_session, class: 'DutyCalculator::UserSession' do
    commodity_code   { nil }
    commodity_source { 'uk' }
    referred_service { nil }
    trade_defence    { nil }
    zero_mfn_duty    { nil }
    other_country_of_origin { '' }

    initialize_with do
      answers = POSSIBLE_ANSWERS.each_with_object({}) do |answer_method, acc|
        acc[answer_method] = public_send(answer_method) if respond_to?(answer_method)
      end

      session = { 'answers' => answers.merge('other_country_of_origin' => other_country_of_origin) }
      session.merge!(attributes.stringify_keys.except(*answers.keys))

      DutyCalculator::UserSession.new(session)
    end
  end

  trait :with_commodity_information do
    commodity_code { '0702000007' }
    commodity_source { 'uk' }
    referred_service { 'uk' }
  end

  trait :with_meursing_commodity do
    commodity_code { '0103921100' }
    commodity_source { 'xi' }
    referred_service { 'xi' }
  end

  trait :with_non_meursing_commodity do
    commodity_code { '0702000007' }
    commodity_source { 'xi' }
    referred_service { 'xi' }
  end

  trait :with_import_date do
    import_date { '2025-01-01' }
  end

  trait :with_import_destination do
    import_destination { 'XI' }
  end

  trait :with_country_of_origin do
    country_of_origin { 'GB' }
    other_country_of_origin { '' }
  end

  trait :with_trader_scheme do
    trader_scheme { 'yes' }
  end

  trait :without_trader_scheme do
    trader_scheme { 'no' }
  end

  trait :with_certificate_of_origin do
    certificate_of_origin { 'yes' }
  end

  trait :without_certificate_of_origin do
    certificate_of_origin { 'no' }
  end

  trait :with_small_turnover do
    annual_turnover { 'yes' }
  end

  trait :with_large_turnover do
    annual_turnover { 'no' }
  end

  trait :with_planned_processing do
    planned_processing { 'commercial_purposes' }
  end

  trait :with_unacceptable_processing do
    planned_processing { 'commercial_purposes' }
  end

  trait :with_customs_value do
    customs_value { { 'monetary_value' => '1200' } }
  end

  trait :with_measure_amount do
    measure_amount { { 'dtn' => '100' } }
  end

  trait :with_coerced_measure_amount do
    measure_amount { { 'kgm' => '100' } }
  end

  trait :with_compound_measure_amount do
    measure_amount { { 'hlt' => '45', 'asv' => '40' } }
  end

  trait :with_coerced_compound_measure_amount do
    measure_amount { { 'ltr' => '45', 'asv' => '40' } }
  end

  trait :with_sucrose_measure_amount do
    measure_amount { { 'kgm' => '16320', 'brx' => '80' } }
  end

  trait :with_retail_price_measure_amount do
    measure_amount { { 'ret' => '1000' } }
  end

  trait :with_trade_defence do
    trade_defence { true }
  end

  trait :with_final_use do
    final_use { 'yes' }
  end

  trait :without_final_use do
    final_use { 'no' }
  end

  trait :deltas_applicable do
    import_destination { 'XI' }
    country_of_origin { 'OTHER' }
    other_country_of_origin { 'AR' }
    trade_defence { false }
    zero_mfn_duty { false }
    trader_scheme { 'yes' }
    final_use { 'yes' }
    planned_processing { 'commercial_processing' } # Either this needs to be true or annual_turnover is < 500k
  end

  trait :with_vat do
    vat { 'VATZ' }
  end

  trait :with_additional_codes do
    additional_code do
      {
        'uk' => {
          '105' => '2340',
          '103' => '2600',
        },
        'xi' => {
          '105' => '2340',
          '103' => '2600',
          '142' => '2601',
        },
      }
    end
  end

  trait :with_meursing_additional_code do
    meursing_additional_code { '000' }
  end

  trait :with_excise_additional_codes do
    excise do
      {
        '306' => '444',
        'DBC' => '369',
      }
    end
  end

  trait :with_eu_to_ni_route do
    import_destination { 'XI' }
    country_of_origin { 'PL' }
  end

  trait :with_gb_to_ni_route do
    import_destination { 'XI' }
    country_of_origin { 'GB' }
  end

  trait :with_row_to_ni_route do
    import_destination { 'XI' }
    country_of_origin { 'OTHER' }
    other_country_of_origin { 'AR' }
  end

  trait :with_row_to_gb_route do
    import_destination { 'UK' }
    country_of_origin { 'AR' }
  end

  trait :with_eu_to_gb_route do
    import_destination { 'UK' }
    country_of_origin { 'PL' }
  end

  trait :with_ni_to_gb_route do
    import_destination { 'UK' }
    country_of_origin { 'XI' }
  end

  trait :with_document_codes do
    document_code do
      {
        'uk' => {
          '103' => 'N851',
          '105' => 'C644',
        },
        'xi' => {
          '142' => 'N851',
          '353' => 'Y929',
        },
      }
    end
  end

  trait :with_no_document_code_selected do
    document_code do
      {
        'uk' => {
          '103' => 'None',
          '105' => 'None',
        },
        'xi' => {
          '142' => 'None',
          '353' => 'None',
        },
      }
    end
  end

  trait :with_no_duty_route_eu do
    country_of_origin { 'RO' }
    import_destination { 'XI' }
  end

  trait :with_no_duty_route_gb do
    country_of_origin { 'XI' }
    import_destination { 'UK' }
  end

  trait :with_possible_duty_route_into_ni do
    country_of_origin { 'GB' }
    import_destination { 'XI' }
  end

  trait :with_possible_duty_route_into_gb do
    country_of_origin { 'IN' }
    import_destination { 'UK' }
  end

  trait :zero_mfn_duty do
    zero_mfn_duty { true }
  end

  trait :with_multiple_stopping_condition_document_answers do
    document_code do
      {
        'uk' => {
          '103' => 'None',
          '105' => 'None',
        },
      }
    end
  end

  trait :with_a_single_stopping_condition_document_answer do
    document_code do
      {
        'uk' => {
          '103' => 'None',
          '105' => 'N990',
        },
      }
    end
  end
end
