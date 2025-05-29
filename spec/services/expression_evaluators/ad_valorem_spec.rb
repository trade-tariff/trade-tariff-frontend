RSpec.describe ExpressionEvaluators::AdValorem, :user_session do
  subject(:evaluator) { described_class.new(measure, component) }

  let(:measure) do
    Api::Measure.new(
      'id' => 20_001_033,
      'duty_expression' => {
        'base' => '8.00 %',
        'formatted_base' => '<span>8.00</span> %',
      },
      'measure_type' => {
        'description' => 'Third country duty',
        'national' => nil,
        'measure_type_series_id' => 'C',
        'id' => '103',
      },
    )
  end
  let(:component) do
    Api::MeasureComponent.new(
      {
        'duty_expression_id' => '01',
        'duty_amount' => 8.0,
        'monetary_unit_code' => nil,
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => nil,
        'duty_expression_description' => '% or amount',
        'duty_expression_abbreviation' => '%',
        'measurement_unit_qualifier_code' => nil,
      },
    )
  end

  let(:expected_evaluation) do
    {
      calculation: '8.00% * £30.00',
      formatted_value: '£2.40',
      value: 2.4,
    }
  end

  let(:session_attributes) do
    {
      'customs_value' => {
        'insurance_cost' => '10',
        'monetary_value' => '10',
        'shipping_cost' => '10',
      },
      'measure_amount' => {
        'dtn' => '120',
      },
    }
  end

  let(:user_session) { build(:user_session, session_attributes) }

  it 'returns a properly calculated evaluation' do
    expect(evaluator.call).to eq(expected_evaluation)
  end
end
