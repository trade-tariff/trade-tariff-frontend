RSpec.describe ExpressionEvaluators::RetailPrice, :user_session do
  subject(:evaluator) { described_class.new(measure, measure_component) }

  include_context 'with a fake commodity'

  let(:user_session) { build(:user_session, :with_retail_price_measure_amount, commodity_code: commodity.code) }

  let(:measure) { commodity.import_measures.first }
  let(:measure_component) { measure.measure_components.first }

  let(:commodity) do
    build(
      :commodity,
      :with_retail_price_measure_units,
      import_measures: [
        attributes_for(
          :measure,
          :excise,
          measure_components: [
            attributes_for(:measure_component, :with_retail_price_measure_units),
          ],
        ),
      ],
    )
  end

  let(:expected_evaluation) do
    {
      calculation: '16.50% * £1,000.00',
      value: 165.0,
      formatted_value: '£165.00',
    }
  end

  it { expect(evaluator.call).to eq(expected_evaluation) }

  it_behaves_like 'a measure unit presentable' do
    let(:expected_presented_unit) do
      {
        answer: '1000',
        multiplier: 1,
        unit: '£',
        original_unit: nil,
      }
    end

    let(:expected_applicable_unit) do
      {
        'measurement_unit_code' => 'RET',
        'measurement_unit_qualifier_code' => nil,
        'unit' => '£',
        'multiplier' => nil,
        'original_unit' => nil,
      }
    end
  end

  it_behaves_like 'an evaluation that uses the measure unit merger'
end
