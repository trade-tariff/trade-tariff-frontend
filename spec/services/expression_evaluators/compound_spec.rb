RSpec.describe ExpressionEvaluators::Compound, :user_session do
  subject(:evaluator) { described_class.new(measure, nil) }

  let(:measure) do
    build(
      :measure,
      :third_country_tariff,
      id: 3_211_138,
      measure_components:,
    )
  end

  let(:measure_components) do
    [
      {
        'duty_expression_id' => '01',
        'duty_amount' => 13.8,
        'monetary_unit_code' => nil,
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => nil,
        'duty_expression_description' => '% or amount',
        'duty_expression_abbreviation' => '%',
        'measurement_unit_qualifier_code' => nil,
      },
      {
        'duty_expression_id' => '15',
        'duty_amount' => 13.0,
        'monetary_unit_code' => 'GBP',
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => 'DTN',
        'duty_expression_description' => 'Minimum',
        'duty_expression_abbreviation' => 'MIN',
        'measurement_unit_qualifier_code' => nil,
      },
      {
        'duty_expression_id' => '17',
        'duty_amount' => 15.0,
        'monetary_unit_code' => 'GBP',
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => 'DTN',
        'duty_expression_description' => 'Maximum',
        'duty_expression_abbreviation' => 'MAX',
        'measurement_unit_qualifier_code' => nil,
      },
      {
        'duty_expression_id' => '36',
        'duty_amount' => 7.0,
        'monetary_unit_code' => 'GBP',
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => 'DTN',
        'duty_expression_description' => '-',
        'duty_expression_abbreviation' => '-',
        'measurement_unit_qualifier_code' => nil,
      },
    ]
  end

  let(:user_session) do
    build(
      :user_session,
      :with_commodity_information,
      :with_customs_value,
      :with_measure_amount,
      commodity_code: '0102291010',
    )
  end

  let(:expected_evaluation) do
    {
      calculation: '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr>',
      formatted_value: '£800.00',
      value: 800.0,
    }
  end

  it { expect(evaluator.call).to eq(expected_evaluation) }

  context 'when a resolved duty expression is returned' do
    let(:measure) do
      build(
        :measure,
        :third_country_tariff,
        :with_resolved_duty_expression,
        id: 3_211_138,
        measure_components:,
      )
    end

    let(:expected_evaluation) do
      {
        calculation: '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr><br><span>9.00</span> % <strong>+ <span>0.00</span> EUR / <abbr title="Hectokilogram">100 kg</abbr></strong> MAX <span>24.20</span> % <strong>+ <span>0.00</span> EUR / <abbr title="Hectokilogram">100 kg</abbr></strong>',
        formatted_value: '£800.00',
        value: 800.0,
      }
    end

    it { expect(evaluator.call).to eq(expected_evaluation) }
  end
end
