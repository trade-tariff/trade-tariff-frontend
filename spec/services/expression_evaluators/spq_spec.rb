RSpec.describe ExpressionEvaluators::Spq, :user_session do
  subject(:evaluator) { described_class.new(measure, component) }

  include_context 'with a fake commodity'

  let(:commodity) { build(:commodity, :with_spq_measurement_units) }

  let(:user_session) do
    build(
      :user_session,
      :with_excise_additional_codes,
      :with_commodity_information,
      measure_amount: {
        'spr' => '5', # SPQ
        'asv' => '3.49', # ASVX + SPQ
        'ltr' => '1000', # ASVX + SPQ
        'lpa' => '34.9', # LPA + SPQ
      },
    )
  end

  let(:measure) do
    build(
      :measure,
      :excise,
      additional_code: attributes_for(:additional_code, :excise_spq),
      measure_conditions: [
        attributes_for(
          :measure_condition,
          :spq_positive,
          id: '-1010137394',
          measure_condition_components:,
        ),
      ],
    )
  end

  let(:component) do
    measure
      .measure_conditions
      .first
      .measure_condition_components
      .last
  end

  context 'when the measure is LPA-based' do
    let(:measure_condition_components) do
      [
        attributes_for(:measure_condition_component, :spq_lpa, id: '-1010137394-01'),
        attributes_for(:measure_condition_component, :spq, id: '-1010137394-02'),
      ]
    end

    let(:expected_evaluation) do
      {
        calculation: "<span>9.27</span> GBP / <abbr title='Litre pure (100%) alcohol'>l alc. 100%</abbr> - £1.00  / for each litre of pure alcohol, multiplied by the SPR discount",
        formatted_value: '£174.50',
        value: 174.5, # 1 * 34.9 * 5
      }
    end

    it { expect(evaluator.call).to eq(expected_evaluation) }
  end

  context 'when the measure is ASVX-based' do
    let(:measure_condition_components) do
      [
        attributes_for(
          :measure_condition_component,
          :spq_asvx,
          id: '-1010137394-01',
        ),
        attributes_for(
          :measure_condition_component,
          :spq,
          id: '-1010137394-02',
        ),
      ]
    end

    let(:expected_evaluation) do
      {
        calculation: "<span>9.27</span> GBP / <abbr title='Litre pure (100%) alcohol'>l alc. 100%</abbr> - £1.00  / for each litre of pure alcohol, multiplied by the SPR discount",
        formatted_value: '£174.50',
        value: 174.5, # 1 * 10 * 3.49 * 5
      }
    end

    it { expect(evaluator.call).to eq(expected_evaluation) }
  end
end
