require 'spec_helper'

RSpec.describe MeasureType do
  shared_examples 'an API semantic role' do |role, legacy_attributes|
    describe "##{role}?" do
      subject(:result) { measure_type.public_send("#{role}?") }

      let(:measure_type) do
        build(
          :measure_type,
          id: 'FOO',
          measure_type_series_id: 'Z',
          semantic_roles:,
        )
      end

      let(:semantic_roles) { [] }

      context 'when the API supplies the role' do
        let(:semantic_roles) { [role] }

        it { is_expected.to be(true) }
      end

      context 'when the API supplies no roles' do
        it { is_expected.to be(false) }
      end

      context 'when the API supplies an unrelated role' do
        let(:semantic_roles) { %w[future_role] }

        it { is_expected.to be(false) }
      end

      context 'when an old matching ID or series has no role' do
        let(:measure_type) do
          build(:measure_type, **legacy_attributes, semantic_roles: [])
        end

        it { is_expected.to be(false) }
      end
    end
  end

  it_behaves_like 'an API semantic role', 'mfn_no_authorized_use', { id: '103' }
  it_behaves_like 'an API semantic role', 'provides_unit_context', { id: '103' }
  it_behaves_like 'an API semantic role', 'safeguard', { id: '696' }
  it_behaves_like 'an API semantic role', 'supplementary', { id: '109' }
  it_behaves_like 'an API semantic role', 'supplementary_unit_import_only', { id: '110' }
  it_behaves_like 'an API semantic role', 'cds_proofs_of_origin', { id: '142' }
  it_behaves_like 'an API semantic role', 'prohibitive', { measure_type_series_id: 'A' }

  describe '#duties_permitted?' do
    subject(:measure_type) do
      build(:measure_type,
            measure_component_applicable_code:)
    end

    context 'when the component applicable code is `0`' do
      let(:measure_component_applicable_code) { 0 }

      it { is_expected.to be_duties_permitted }
    end

    context 'when the component applicable code is anything else' do
      let(:measure_component_applicable_code) { 9 }

      it { is_expected.not_to be_duties_permitted }
    end
  end

  describe '#duties_mandatory?' do
    subject(:measure_type) do
      build(:measure_type,
            measure_component_applicable_code:)
    end

    context 'when the component applicable code is `1`' do
      let(:measure_component_applicable_code) { 1 }

      it { is_expected.to be_duties_mandatory }
    end

    context 'when the component applicable code is anything else' do
      let(:measure_component_applicable_code) { 9 }

      it { is_expected.not_to be_duties_mandatory }
    end
  end

  describe '#duties_not_permitted?' do
    subject(:measure_type) do
      build(:measure_type,
            measure_component_applicable_code:)
    end

    context 'when the component applicable code is `2`' do
      let(:measure_component_applicable_code) { 2 }

      it { is_expected.to be_duties_not_permitted }
    end

    context 'when the component applicable code is anything else' do
      let(:measure_component_applicable_code) { 9 }

      it { is_expected.not_to be_duties_not_permitted }
    end
  end

  describe '#description' do
    shared_examples_for 'an overridden measure type description' do |measure_type_id, geographical_area_id, expected_description|
      subject(:description) { measure.measure_type.description }

      let(:measure) do
        build(:measure, measure_type_id:,
                        geographical_area_id:)
      end

      it { is_expected.to eq(expected_description) }
    end

    it_behaves_like 'an overridden measure type description', '103', '1080', 'UK-CD Customs Union'

    context 'when the measure type is loaded without a measure and no geographical_area_id is set' do
      subject(:description) { measure_type.description }

      let(:measure_type) { build(:measure_type, description: 'Bar') }

      it { is_expected.to eq('Bar') }
    end

    context 'when the measure type is loaded without a measure and a geographical_area_id is set' do
      subject(:description) { measure_type.description }

      let(:measure_type) { build(:measure_type, id: '103', description: 'Foo', geographical_area_id: '1080') }

      it { is_expected.to eq('UK-CD Customs Union') }
    end

    context 'when there are no matching locales' do
      subject(:description) { measure.measure_type.description }

      let(:measure) { build(:measure, measure_type_description: 'Bar') }

      it { is_expected.to eq('Bar') }
    end

    context 'when a removed Crown Dependencies override would previously have matched' do
      subject(:description) { measure.measure_type.description }

      let(:measure) do
        build(:measure, measure_type_id: '103',
                        geographical_area_id: '1400',
                        measure_type_description: 'Third country duty')
      end

      it { is_expected.to eq('Third country duty') }
    end
  end

  describe '#abbreviation' do
    subject(:abbreviation) { measure.measure_type.abbreviation }

    context 'when description contains Prohibition' do
      let(:measure) { build(:measure, measure_type_description: 'Prohibition text') }

      it { is_expected.to eq('Prohibition') }
    end

    context 'when description contains Restriction' do
      let(:measure) { build(:measure, measure_type_description: 'Restriction text') }

      it { is_expected.to eq('Restriction') }
    end

    context 'when description does not cantain any of above' do
      let(:measure) { build(:measure, measure_type_description: 'Other text') }

      it { is_expected.to eq('Control') }
    end
  end

  describe '#details_text' do
    context 'when markdown file exists' do
      subject(:measure_type) { build(:measure_type, id: '103') }

      it { expect(measure_type.details_text).to match(/Third country/) }
    end

    context 'when markdown file does not exist for measure type' do
      subject(:measure_type) { build(:measure_type, id: '911') }

      it { expect(measure_type.details_text).to eq('') }
    end
  end
end
