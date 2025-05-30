RSpec.describe DutyCalculator::Api::MeasureCondition do
  subject(:measure_condition) do
    described_class.new(
      condition_measurement_unit_code:,
      condition_monetary_unit_code:,
    )
  end

  let(:condition_measurement_unit_code) { nil }
  let(:condition_monetary_unit_code) { nil }

  it_behaves_like 'a resource that has attributes',
                  id: 'flibble',
                  condition_code: 'B',
                  condition: 'B: Presentation of a certificate/licence/document',
                  requirement: nil,
                  action: 'The entry into free circulation is not allowed',
                  duty_expression: '',
                  condition_duty_amount: nil,
                  condition_monetary_unit_code: nil,
                  monetary_unit_abbreviation: nil,
                  condition_measurement_unit_code: nil,
                  condition_measurement_unit_qualifier_code: nil,
                  measure_condition_components: []

  it_behaves_like 'a resource that has an enum', :action_code, {
    applicable: %w[01 24 25 26 27 28 29 34 36],
    not_applicable: %w[04 05 06 07 08 09 10 16 30],
    stopping: %w[08],
  }

  describe '#requirement_operator' do
    shared_examples_for 'a measure condition operator translation' do |input_operator, output_operator|
      it "translates #{input_operator} to #{output_operator}" do
        measure_condition.requirement_operator = input_operator

        expect(measure_condition.requirement_operator).to eq(output_operator)
      end
    end

    it_behaves_like 'a measure condition operator translation', '=<', '<='
    it_behaves_like 'a measure condition operator translation', '=>', '>='
    it_behaves_like 'a measure condition operator translation', '>', '>'
    it_behaves_like 'a measure condition operator translation', '<', '<'
    it_behaves_like 'a measure condition operator translation', '=', '='
    it_behaves_like 'a measure condition operator translation', nil, nil
  end

  describe '#expresses_unit?' do
    context 'when condition_measurement_unit_code is present' do
      let(:condition_measurement_unit_code) { 'DTN' }

      it { is_expected.to be_expresses_unit }
    end

    context 'when condition_measurement_unit_code is not present' do
      let(:condition_measurement_unit_code) { nil }

      it { is_expected.not_to be_expresses_unit }
    end
  end

  describe '#expresses_document?' do
    shared_examples_for 'a measure condition that requires a document' do |document_code, condition_code|
      subject(:measure_condition) { described_class.new(document_code:, condition_code:) }

      it { is_expected.to be_expresses_document }
    end

    it_behaves_like 'a measure condition that requires a document', 'C990', 'B'
    it_behaves_like 'a measure condition that requires a document', 'C990', 'H'
    it_behaves_like 'a measure condition that requires a document', 'C990', 'E'
    it_behaves_like 'a measure condition that requires a document', 'C990', 'A'
    it_behaves_like 'a measure condition that requires a document', 'C990', 'C'
    it_behaves_like 'a measure condition that requires a document', 'C990', 'I'

    context 'when the condition_code is an unsupported value' do
      subject(:measure_condition) { described_class.new(document_code:, condition_code:) }

      let(:document_code) { 'C990' }
      let(:condition_code) { 'Z' }

      it { is_expected.not_to be_expresses_document }
    end

    context 'when the condition_code is blank' do
      subject(:measure_condition) { described_class.new(document_code:, condition_code:) }

      let(:document_code) { 'C990' }
      let(:condition_code) { nil }

      it { is_expected.not_to be_expresses_document }
    end

    context 'when the document code is blank' do
      subject(:measure_condition) { described_class.new(document_code:, condition_code:) }

      let(:document_code) { nil }
      let(:condition_code) { 'B' }

      it { is_expected.not_to be_expresses_document }
    end
  end

  describe '#document_code' do
    subject(:measure_condition) { described_class.new('document_code' => document_code) }

    context 'when the measure condition has a document code' do
      let(:document_code) { 'C990' }

      it { expect(measure_condition.document_code).to eq('C990') }
    end

    context 'when the measure condition does not have a document code' do
      let(:document_code) { '' }

      it { expect(measure_condition.document_code).to eq('None') }
    end
  end

  describe '#certificate_description' do
    subject(:measure_condition) { described_class.new('document_code' => document_code, certificate_description: 'Flibble') }

    context 'when the measure condition has a document code' do
      let(:document_code) { 'C990' }

      it { expect(measure_condition.certificate_description).to eq('C990 - Flibble') }
    end

    context 'when the measure condition does not have a document code' do
      let(:document_code) { '' }

      it { expect(measure_condition.certificate_description).to eq('None of the above') }
    end
  end

  describe '#condition_measurement_unit' do
    subject(:measure_condition) { described_class.new(condition_measurement_unit_code:, condition_measurement_unit_qualifier_code:) }

    context 'when the measure condition has a measurement unit code' do
      let(:condition_measurement_unit_code) { 'DTN' }
      let(:condition_measurement_unit_qualifier_code) { 'R' }

      it { expect(measure_condition.condition_measurement_unit).to eq('DTNR') }
    end

    context 'when the measure condition does not have a measurement unit code' do
      let(:condition_measurement_unit_code) { nil }
      let(:condition_measurement_unit_qualifier_code) { nil }

      it { expect(measure_condition.condition_measurement_unit).to be_nil }
    end
  end

  describe '#lpa_based?' do
    subject(:measure_condition) { build(:duty_calculator_measure_condition, measure_condition_components:) }

    context 'when the measure condition components include an LPA component' do
      let(:measure_condition_components) { [attributes_for(:duty_calculator_measure_condition_component, :spq_lpa)] }

      it { is_expected.to be_lpa_based }
    end

    context 'when the measure condition components do not include an LPA component' do
      let(:measure_condition_components) { [attributes_for(:duty_calculator_measure_condition_component, :spq)] }

      it { is_expected.not_to be_lpa_based }
    end

    context 'when the measure condition components are empty' do
      let(:measure_condition_components) { [] }

      it { is_expected.not_to be_lpa_based }
    end
  end

  describe '#asvx_based?' do
    subject(:measure_condition) { build(:duty_calculator_measure_condition, measure_condition_components:) }

    context 'when the measure condition components include an ASVX component' do
      let(:measure_condition_components) { [attributes_for(:duty_calculator_measure_condition_component, :spq_asvx)] }

      it { is_expected.to be_asvx_based }
    end

    context 'when the measure condition components do not include an ASVX component' do
      let(:measure_condition_components) { [attributes_for(:duty_calculator_measure_condition_component, :spq)] }

      it { is_expected.not_to be_asvx_based }
    end

    context 'when the measure condition components are empty' do
      let(:measure_condition_components) { [] }

      it { is_expected.not_to be_asvx_based }
    end
  end
end
