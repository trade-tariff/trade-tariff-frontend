RSpec.describe ExpressionEvaluators::AlcoholVolumeMeasureUnit, :user_session do
  subject(:evaluator) { described_class.new(measure, measure.component) }

  include_context 'with a fake commodity'

  let(:measure) { commodity.import_measures.first }
  let(:measure_component) { measure.measure_components.first }

  context 'when there is an applicable multiplier on the volume unit' do
    let(:user_session) do
      build(
        :user_session,
        :with_commodity_information,
        :with_customs_value,
        :with_coerced_compound_measure_amount,
      )
    end
    let(:commodity) { build(:commodity, :with_compound_measure_units) }

    let(:expected_evaluation) do
      {
        calculation: '<span>0.50</span> GBP / <abbr title="%vol">% vol/hl</abbr> + <span>2.60</span> GBP / <abbr title="Hectolitre">hl</abbr>',
        formatted_value: '£9.00', # Result of converting volume input in litres to hectolitres
        value: 9.0,
      }
    end

    it 'returns the evaluation with the multiplier applied' do
      expect(evaluator.call).to eq(expected_evaluation)
    end

    it_behaves_like 'an evaluation that uses the measure unit merger'
  end

  context 'when there are no applicable multipliers' do
    let(:user_session) do
      build(
        :user_session,
        :with_commodity_information,
        :with_customs_value,
        :with_compound_measure_amount,
      )
    end
    let(:commodity) { build(:commodity, :with_compound_measure_units_no_multiplier) }

    let(:expected_evaluation) do
      {
        calculation: '<span>0.50</span> GBP / <abbr title="%vol">% vol/hl</abbr> + <span>2.60</span> GBP / <abbr title="Hectolitre">hl</abbr>',
        formatted_value: '£900.00', # Result of no conversion to litres
        value: 900.0,
      }
    end

    it { expect(evaluator.call).to eq(expected_evaluation) }

    it_behaves_like 'an evaluation that uses the measure unit merger'
  end

  context 'with an irregular value' do
    let(:user_session) do
      build(
        :user_session,
        :with_commodity_information,
        :with_customs_value,
        :with_compound_measure_amount,
      )
    end

    it 'rounds values down' do
      expect(evaluator.formatted_value(2.789)).to(eq('£2.78'))
    end
  end
end
