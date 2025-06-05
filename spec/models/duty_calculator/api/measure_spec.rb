RSpec.describe DutyCalculator::Api::Measure, :user_session do
  subject(:measure) { build(:duty_calculator_measure) }

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      :with_document_codes,
      :with_excise_additional_codes,
    )
  end
  let(:measure_components) do
    [
      {
        'duty_expression_id' => '01',
        'duty_amount' => 10.0,
        'monetary_unit_code' => nil,
        'monetary_unit_abbreviation' => nil,
        'measurement_unit_code' => nil,
        'duty_expression_description' => '% or amount',
        'duty_expression_abbreviation' => '%',
        'measurement_unit_qualifier_code' => nil,
      },
    ]
  end

  it_behaves_like 'a has_many relationship', :measure_conditions
  it_behaves_like 'a has_many relationship', :measure_components
  it_behaves_like 'a has_many relationship', :resolved_measure_components

  it_behaves_like 'a has_one relationship', :measure_type
  it_behaves_like 'a has_one relationship', :geographical_area
  it_behaves_like 'a has_one relationship', :duty_expression
  it_behaves_like 'a has_one relationship', :order_number
  it_behaves_like 'a has_one relationship', :additional_code
  it_behaves_like 'a has_one relationship', :suspension_legal_act

  it_behaves_like 'a resource that has attributes', measure_conditions: [],
                                                    measure_components: [],
                                                    id: -582_007,
                                                    origin: 'uk',
                                                    effective_start_date: '2020-08-01T00:00:00.000Z',
                                                    effective_end_date: nil,
                                                    import: true,
                                                    excise: false,
                                                    vat: true,
                                                    legal_acts: [],
                                                    reduction_indicator: 1,
                                                    national_measurement_units: [],
                                                    excluded_countries: [],
                                                    footnotes: [],
                                                    meursing: false,
                                                    resolved_duty_expression: ''

  describe '#evaluator' do
    subject(:measure) { build(:duty_calculator_measure, :third_country_tariff, source: 'xi', measure_components:) }

    shared_examples_for 'a measure evaluator' do |expected_evaluator|
      it 'instantiates the correct evaluator' do
        allow(expected_evaluator).to receive(:new)

        measure.evaluator

        expect(expected_evaluator).to have_received(:new).with(measure, (measure.component unless expected_evaluator == DutyCalculator::ExpressionEvaluators::Compound))
      end
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::AdValorem do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :ad_valorem)] }
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::MeasureUnit do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_measure_units, :single_measure_unit)] }
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::AlcoholVolumeMeasureUnit do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_measure_units, :alcohol_volume)] }
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::SucroseMeasureUnit do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_measure_units, :sucrose)] }
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::RetailPrice do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_retail_price_measure_units)] }
    end

    it_behaves_like 'a measure evaluator', DutyCalculator::ExpressionEvaluators::Compound do
      let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_measure_units), attributes_for(:duty_calculator_measure_component, :ad_valorem)] }
    end
  end

  describe '#evaluator_for_compound_component' do
    subject(:measure) { described_class.new({}) }

    let(:component) { instance_double(DutyCalculator::Api::MeasureComponent) }
    let(:ad_valorem) { false }
    let(:specific_duty) { false }
    let(:retail_price) { false }
    let(:alcohol_volume) { false }
    let(:sucrose) { false }
    let(:spq) { false }

    before do
      allow(component).to receive_messages(ad_valorem?: ad_valorem, specific_duty?: specific_duty, retail_price?: retail_price, alcohol_volume?: alcohol_volume, sucrose?: sucrose, spq?: spq)
    end

    shared_examples_for 'a compound measure evaluator' do |expected_evaluator|
      it 'instantiates the correct evaluator' do
        allow(expected_evaluator).to receive(:new)

        measure.evaluator_for_compound_component(component)

        expect(expected_evaluator).to have_received(:new).with(measure, component)
      end
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::AdValorem do
      let(:ad_valorem) { true }
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::MeasureUnit do
      let(:specific_duty) { true }
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::AlcoholVolumeMeasureUnit do
      let(:specific_duty) { true }
      let(:alcohol_volume) { true }
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::SucroseMeasureUnit do
      let(:specific_duty) { true }
      let(:sucrose) { true }
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::RetailPrice do
      let(:specific_duty) { true }
      let(:retail_price) { true }
    end

    it_behaves_like 'a compound measure evaluator', DutyCalculator::ExpressionEvaluators::Spq do
      let(:spq) { true }
    end
  end

  describe '#component' do
    subject(:measure) do
      described_class.new(
        'id' => 2_046_828,
        'meta' => {
          'duty_calculator' => {
            'source' => 'uk',
          },
        },
        'duty_expression' => {
          'base' => '35.10 EUR / 100 kg',
          'formatted_base' => "<span>35.10</span> EUR / <abbr title='Hectokilogram'>100 kg</abbr>",
        },
        'measure_type' => {
          'description' => 'Third country duty',
          'national' => nil,
          'measure_type_series_id' => 'C',
          'id' => '103',
        },
        'measure_conditions' => [],
        'measure_components' => [
          {
            'duty_expression_id' => '01',
            'duty_amount' => 35.1,
            'monetary_unit_code' => 'EUR',
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => 'DTN',
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
          },
          {
            'duty_expression_id' => '02',
            'duty_amount' => 40,
            'monetary_unit_code' => 'EUR',
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => 'DTN',
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => 'R',
          },
        ],
        'resolved_measure_components' => [],
      )
    end

    it 'returns the correct component' do
      expect(measure.component.duty_expression_id).to eq('01')
    end
  end

  describe '#all_duties_zero?' do
    subject(:measure) do
      described_class.new(
        'id' => 2_046_828,
        'meta' => {
          'duty_calculator' => {
            'source' => 'uk',
          },
        },
        'duty_expression' => {
          'base' => '35.10 EUR / 100 kg',
          'formatted_base' => "<span>35.10</span> EUR / <abbr title='Hectokilogram'>100 kg</abbr>",
        },
        'measure_type' => {
          'description' => 'Third country duty',
          'national' => nil,
          'measure_type_series_id' => 'C',
          'id' => '103',
        },
        'vat' => vat,
        'measure_conditions' => [],
        'measure_components' => [
          {
            'duty_expression_id' => '01',
            'duty_amount' => duty_amount,
            'monetary_unit_code' => 'EUR',
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => 'DTN',
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
          },
        ],
        'resolved_measure_components' => [],
      )
    end

    let(:duty_amount) { 35 }
    let(:vat) { false }

    context 'when the measure is VAT' do
      let(:vat) { true }

      it 'returns false' do
        expect(measure.all_duties_zero?).to be false
      end
    end

    it 'returns false' do
      expect(measure.all_duties_zero?).to be false
    end

    context 'when duty amount on the measure is 0' do
      let(:duty_amount) { 0 }

      it 'returns true' do
        expect(measure.all_duties_zero?).to be true
      end
    end
  end

  describe '#vat_type' do
    subject(:measure) do
      described_class.new(
        'id' => 2_046_828,
        'measure_type' => {
          'description' => 'Third country duty',
          'national' => nil,
          'measure_type_series_id' => 'C',
          'id' => '103',
        },
        'vat' => vat,
        'measure_conditions' => [],
        'additional_code' => additional_code,
      )
    end

    let(:vat) { true }
    let(:additional_code) do
      {
        'code' => 'foo',
        'description' => 'COFCO International Argentina S.A.',
        'formatted_description' => 'COFCO International Argentina S.A.',
      }
    end

    context 'when the measure is not VAT' do
      let(:vat) { false }

      it 'returns nil' do
        expect(measure.vat_type).to be_nil
      end
    end

    context 'when the measure is VAT' do
      context 'when there is no additional code' do
        let(:additional_code) { {} }

        it 'returns VAT' do
          expect(measure.vat_type).to eq('VAT')
        end
      end

      it 'returns foo' do
        expect(measure.vat_type).to eq('foo')
      end
    end
  end

  describe '#applicable_components' do
    subject(:measure) do
      described_class.new(
        'id' => 20_121_795,
        'meta' => { 'duty_calculator' => { 'source' => 'uk' } },
        'measure_type' => { 'id' => '117' },
        'measure_conditions' => measure_conditions,
        'measure_components' => measure_components,
        'resolved_measure_components' => resolved_measure_components,
      )
    end

    context 'when there are only measure components' do
      let(:measure_components) do
        [
          {
            'duty_expression_id' => '01',
            'duty_amount' => 0.0,
            'monetary_unit_code' => nil,
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => nil,
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
            'meta' => nil,
          },
        ]
      end

      let(:resolved_measure_components) { [] }
      let(:measure_conditions) { [] }

      it 'returns the correct components' do
        expect(measure.applicable_components.as_json).to eq(measure.measure_components.as_json)
      end
    end

    context 'when there are only resolved measure components' do
      let(:measure_components) { [] }

      let(:resolved_measure_components) do
        [
          {
            'duty_expression_id' => '01',
            'duty_amount' => 0.0,
            'monetary_unit_code' => nil,
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => nil,
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
            'meta' => nil,
          },
        ]
      end
      let(:measure_conditions) { [] }

      it 'returns the correct components' do
        expect(measure.applicable_components.as_json).to eq(measure.resolved_measure_components.as_json)
      end
    end

    context 'when there are both resolved and standard measure components' do
      let(:measure_components) do
        [
          {
            'duty_expression_id' => '01',
            'duty_amount' => 0.0,
            'monetary_unit_code' => nil,
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => nil,
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
            'meta' => nil,
          },
        ]
      end

      let(:resolved_measure_components) do
        [
          {
            'duty_expression_id' => '04',
            'duty_amount' => 5.6,
            'monetary_unit_code' => 'EUR',
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => 'DTN',
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
            'meta' => nil,
          },
        ]
      end
      let(:measure_conditions) { [] }

      it 'returns the correct components' do
        expect(measure.applicable_components.as_json).to eq(measure.resolved_measure_components.as_json)
      end
    end

    context 'when there are document measure conditions with a matching document answer' do
      let(:user_session) do
        build(:duty_calculator_user_session, document_code: { 'uk' => { '117' => 'C990' } })
      end

      let(:matching_condition) do
        {
          'action' => 'Apply the mentioned duty',
          'action_code' => '27',
          'certificate_description' => 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)',
          'condition' => 'B: Presentation of a certificate/licence/document',
          'condition_code' => 'B',
          'condition_duty_amount' => nil,
          'condition_measurement_unit_code' => nil,
          'condition_measurement_unit_qualifier_code' => nil,
          'condition_monetary_unit_code' => nil,
          'document_code' => 'C990',
          'duty_expression' => '',
          'monetary_unit_abbreviation' => nil,
          'requirement' => 'Other certificates: End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)',
          'measure_condition_components' => measure_condition_components,
          'meta' => nil,
        }
      end

      let(:unmatching_condition) do
        {
          'action' => 'Measure not applicable',
          'action_code' => '07',
          'certificate_description' => nil,
          'condition' => 'B: Presentation of a certificate/licence/document',
          'condition_code' => 'B',
          'condition_duty_amount' => nil,
          'condition_measurement_unit_code' => nil,
          'condition_measurement_unit_qualifier_code' => nil,
          'condition_monetary_unit_code' => nil,
          'document_code' => '',
          'duty_expression' => '',
          'monetary_unit_abbreviation' => nil,
          'requirement' => nil,
          'measure_condition_components' => [],
          'meta' => nil,
        }
      end

      let(:measure_components) do
        [
          {
            'duty_expression_id' => '01',
            'duty_amount' => 0.0,
            'monetary_unit_code' => nil,
            'monetary_unit_abbreviation' => nil,
            'measurement_unit_code' => nil,
            'duty_expression_description' => '% or amount',
            'duty_expression_abbreviation' => '%',
            'measurement_unit_qualifier_code' => nil,
            'meta' => nil,
          },
        ]
      end

      let(:measure_conditions) { [unmatching_condition, matching_condition] }
      let(:resolved_measure_components) { [] }

      context 'when the component we apply is in the measure components' do
        let(:measure_condition_components) { [] }

        it 'returns the correct components' do
          expect(measure.applicable_components.as_json).to eq(measure.measure_components.as_json)
        end
      end

      context 'when the component we apply is in the measure condition components' do
        let(:measure_condition_components) do
          [
            {
              'id' => '20121795-01',
              'duty_expression_id' => '01',
              'duty_amount' => 10.0,
              'monetary_unit_code' => nil,
              'monetary_unit_abbreviation' => nil,
              'measurement_unit_code' => nil,
              'measurement_unit_qualifier_code' => nil,
              'meta' => nil,
              'duty_expression_abbreviation' => nil,
              'duty_expression_description' => nil,
            },
          ]
        end

        it 'returns the correct components' do
          expect(measure.applicable_components.as_json).to eq(
            [
              {
                'duty_amount' => 10.0,
                'duty_expression_abbreviation' => nil,
                'duty_expression_description' => nil,
                'duty_expression_id' => '01',
                'id' => '20121795-01',
                'measurement_unit_code' => nil,
                'measurement_unit_qualifier_code' => nil,
                'meta' => nil,
                'monetary_unit_abbreviation' => nil,
                'monetary_unit_code' => nil,
              },
            ],
          )
        end
      end
    end
  end

  describe '#expresses_document?' do
    subject(:measure) { described_class.new('measure_conditions' => measure_conditions) }

    context 'when a measure condition requires a document' do
      let(:measure_conditions) do
        [
          {
            'document_code' => 'C990',
            'condition_code' => 'B',
          },
        ]
      end

      it { is_expected.to be_expresses_document }
    end

    context 'when there are no measure conditions that require a document' do
      let(:measure_conditions) do
        [
          {
            'document_code' => nil,
            'condition_code' => 'B',
          },
        ]
      end

      it { is_expected.not_to be_expresses_document }
    end

    context 'when there are no measure conditions' do
      let(:measure_conditions) do
        []
      end

      it { is_expected.not_to be_expresses_document }
    end
  end

  describe '#applicable?' do
    subject(:measure) do
      described_class.new(
        'id' => 20_121_795,
        'meta' => { 'duty_calculator' => { 'source' => 'uk' } },
        'measure_type' => { 'id' => '117' },
        'measure_conditions' => [matching_condition],
        'measure_components' => [],
      )
    end

    context 'when the matching document condition is applicable' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          document_code: { 'uk' => { '117' => 'C990' } },
        )
      end

      let(:matching_condition) do
        {
          'action' => 'Apply the mentioned duty',
          'action_code' => '27',
          'certificate_description' => 'End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)',
          'condition' => 'B: Presentation of a certificate/licence/document',
          'condition_code' => 'B',
          'condition_duty_amount' => nil,
          'condition_measurement_unit_code' => nil,
          'condition_measurement_unit_qualifier_code' => nil,
          'condition_monetary_unit_code' => nil,
          'document_code' => 'C990',
          'duty_expression' => '',
          'monetary_unit_abbreviation' => nil,
          'requirement' => 'Other certificates: End use authorisation ships and platforms (Column 8c, Annex A of Delegated Regulation (EU) 2015/2446)',
          'measure_condition_components' => [],
          'meta' => nil,
        }
      end

      it { is_expected.to be_applicable }
    end

    context 'when the matching document condition is not applicable' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          document_code: { 'uk' => { '117' => 'None' } },
        )
      end

      let(:matching_condition) do
        {
          'action' => 'Measure not applicable',
          'action_code' => '07',
          'certificate_description' => nil,
          'condition' => 'B: Presentation of a certificate/licence/document',
          'condition_code' => 'B',
          'condition_duty_amount' => nil,
          'condition_measurement_unit_code' => nil,
          'condition_measurement_unit_qualifier_code' => nil,
          'condition_monetary_unit_code' => nil,
          'document_code' => '',
          'duty_expression' => '',
          'monetary_unit_abbreviation' => nil,
          'requirement' => nil,
          'measure_condition_components' => [],
          'meta' => nil,
        }
      end

      it { is_expected.not_to be_applicable }
    end

    context 'when the matching threshold condition is applicable' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          measure_amount: { 'asv' => 10.42 },
        )
      end

      let(:matching_condition) do
        {
          'id' => '-1010130922',
          'action' => 'Apply the amount of the action (see components)',
          'action_code' => '01',
          'certificate_description' => nil,
          'condition' => 'E: The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document',
          'condition_code' => 'E',
          'condition_duty_amount' => 14.499999999999998,
          'condition_measurement_unit_code' => 'ASV',
          'condition_measurement_unit_qualifier_code' => nil,
          'condition_monetary_unit_code' => nil,
          'document_code' => '',
          'duty_expression' => "<span>35.62</span> GBP / <abbr title='%vol'>% vol/hl</abbr>",
          'guidance_cds' => nil,
          'guidance_chief' => nil,
          'measure_condition_class' => 'threshold',
          'monetary_unit_abbreviation' => nil,
          'requirement' => "<span>14.50</span> <abbr title='%vol'>% vol</abbr>",
          'requirement_operator' => '=<',
          'threshold_unit_type' => nil,
          'measure_condition_components' => [
            {
              'id' => '-1010130922-01',
              'duty_expression_id' => '01',
              'duty_amount' => 35.62,
              'monetary_unit_code' => 'GBP',
              'monetary_unit_abbreviation' => nil,
              'measurement_unit_code' => 'ASV',
              'measurement_unit_qualifier_code' => 'X',
              'duty_expression_description' => '% or amount',
              'duty_expression_abbreviation' => '%',
            },
          ],
        }
      end

      it { is_expected.to be_applicable }
    end

    context 'when there is no matching condition' do
      let(:matching_condition) { nil }

      it { is_expected.to be_applicable }
    end
  end

  describe '#all_units' do
    subject(:measure) do
      build(
        :duty_calculator_measure,
        measure_components:,
        resolved_measure_components:,
        measure_conditions:,
      )
    end

    let(:measure_components) { [attributes_for(:duty_calculator_measure_component, :with_measure_units)] }
    let(:resolved_measure_components) { [attributes_for(:duty_calculator_measure_component, :with_retail_price_measure_units)] }
    let(:measure_conditions) do
      [
        attributes_for(
          :duty_calculator_measure_condition,
          measure_condition_components: [
            attributes_for(
              :duty_calculator_measure_condition_component,
              :with_measure_units,
            ),
          ],
        ),
      ]
    end

    it { expect(measure.all_units).to eq(%w[DTN RET]) }
  end

  describe '#stopping_condition_met?' do
    context 'when there is a stopping condition with a stopping user session answer' do
      subject(:measure) { build(:duty_calculator_measure, :third_country_tariff_authorised_use, :with_stopping_conditions) }

      let(:user_session) { build(:duty_calculator_user_session, :with_multiple_stopping_condition_document_answers) }

      it { is_expected.to be_stopping_condition_met }
    end

    context 'when there is a stopping condition with no stopping user session answer' do
      subject(:measure) { build(:duty_calculator_measure, :third_country_tariff_authorised_use, :with_stopping_conditions) }

      let(:user_session) { build(:duty_calculator_user_session, :with_a_single_stopping_condition_document_answer) }

      it { is_expected.not_to be_stopping_condition_met }
    end

    context 'when there are no stopping conditions' do
      subject(:measure) { build(:duty_calculator_measure, :third_country_tariff_authorised_use) }

      let(:user_session) { build(:duty_calculator_user_session, :with_a_single_stopping_condition_document_answer) }

      it { is_expected.not_to be_stopping_condition_met }
    end
  end

  describe '#stopping?' do
    context 'when the measure has a measure condition that is stopping' do
      subject(:measure) { build(:duty_calculator_measure, :with_stopping_conditions) }

      it { is_expected.to be_stopping }
    end

    context 'when the measure does not have a measure condition that is stopping' do
      subject(:measure) { build(:duty_calculator_measure) }

      it { is_expected.not_to be_stopping }
    end
  end
end
