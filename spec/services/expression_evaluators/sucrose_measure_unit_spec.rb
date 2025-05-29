RSpec.describe ExpressionEvaluators::SucroseMeasureUnit, :user_session do
  subject(:evaluator) { described_class.new(measure, measure.component) }

  include_context 'with a fake commodity'

  let(:measure) { commodity.import_measures.first }
  let(:measure_component) { measure.measure_components.first }

  let(:user_session) do
    build(
      :user_session,
      :with_commodity_information,
      :with_customs_value,
      :with_sucrose_measure_amount,
    )
  end
  let(:commodity) { build(:commodity, :with_sucrose_measure_units) }

  let(:expected_evaluation) do
    {
      calculation: '<span>0.30</span> GBP / <abbr title="Hectokilogram">100 kg/net/%sacchar.</abbr>',
      value: 3916.8,
      formatted_value: '£3,916.80',
    }
  end

  it { expect(evaluator.call).to eq(expected_evaluation) }

  it_behaves_like 'an evaluation that uses the measure unit merger'
end
