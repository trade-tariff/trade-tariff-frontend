require 'spec_helper'

RSpec.describe MeasureType do
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

  describe '#prohibitive?' do
    subject(:measure_type) do
      build(:measure_type,
            measure_type_series_id:)
    end

    context 'when id lies in prohibitive category' do
      let(:measure_type_series_id) { 'A' }

      it { is_expected.to be_prohibitive }
    end

    context 'when id does not lie in prohibitive category' do
      let(:measure_type_series_id) { 'D' }

      it { is_expected.not_to be_prohibitive }
    end
  end

  describe '#supplementary?' do
    shared_examples_for 'a supplementary measure type' do |measure_type_id|
      subject(:measure_type) { build(:measure_type, id: measure_type_id) }

      it { is_expected.to be_a_supplementary }
    end

    it_behaves_like 'a supplementary measure type', '109'
    it_behaves_like 'a supplementary measure type', '110'
    it_behaves_like 'a supplementary measure type', '111'

    context 'when the measure type id is a non supplementary measure type id' do
      subject(:measure_type) { build(:measure_type, id: 'foo') }

      it { is_expected.not_to be_a_supplementary }
    end
  end

  describe '#supplementary_unit_import_only?' do
    context 'when the measure type id is a supplementary id and import only' do
      subject(:measure_type) { build(:measure_type, id: '110') }

      it { is_expected.to be_a_supplementary_unit_import_only }
    end

    context 'when the measure type id is a supplementary id but not import only' do
      subject(:measure_type) { build(:measure_type, id: '109') }

      it { is_expected.not_to be_a_supplementary_unit_import_only }
    end

    context 'when the measure type id is not supplementary' do
      subject(:measure_type) { build(:measure_type, id: 'foo') }

      it { is_expected.not_to be_a_supplementary_unit_import_only }
    end
  end

  describe '#description' do
    shared_examples_for 'a Channel Island measure type description' do |measure_type_id, geographical_area_id|
      subject(:description) { measure.measure_type.description }

      let(:measure) do
        build(:measure, measure_type_id:,
                        geographical_area_id:)
      end

      it { is_expected.to eq('Channel Islands duty') }
    end

    it_behaves_like 'a Channel Island measure type description', '103', '1400'
    it_behaves_like 'a Channel Island measure type description', '105', '1400'

    context 'when the measure type is loaded without a measure and no geographical_area_id is set' do
      subject(:description) { measure_type.description }

      let(:measure_type) { build(:measure_type, description: 'Bar') }

      it { is_expected.to eq('Bar') }
    end

    context 'when the measure type is loaded without a measure and a geographical_area_id is set' do
      subject(:description) { measure_type.description }

      let(:measure_type) { build(:measure_type, id: '103', description: 'Foo', geographical_area_id: '1400') }

      it { is_expected.to eq('Channel Islands duty') }
    end

    context 'when there are no matching locales' do
      subject(:description) { measure.measure_type.description }

      let(:measure) { build(:measure, measure_type_description: 'Bar') }

      it { is_expected.to eq('Bar') }
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

  describe '#safeguard?' do
    context 'with safeguard measure' do
      subject { build :measure_type, :safeguard }

      it { is_expected.to be_safeguard }
    end

    context 'with non-safeguard measure' do
      subject { build :measure_type, :vat }

      it { is_expected.not_to be_safeguard }
    end
  end

  describe '#mfn_no_authorized_use?' do
    context 'with MFN measure' do
      subject { build :measure_type, :third_country }

      it { is_expected.to be_mfn_no_authorized_use }
    end

    context 'with an authorised used measure' do
      subject { build :measure_type, :third_country_authorised_use }

      it { is_expected.not_to be_mfn_no_authorized_use }
    end

    context 'with non-MFN measure' do
      subject { build :measure_type, :vat }

      it { is_expected.not_to be_mfn_no_authorized_use }
    end
  end

  describe '#excise?' do
    context 'with excise measure' do
      subject { build :measure_type, :excise }

      it { is_expected.to be_excise }
    end

    context 'with non-excise measure' do
      subject { build :measure_type, :vat }

      it { is_expected.not_to be_excise }
    end
  end

  describe '#provides_unit_context?' do
    shared_examples_for 'a provides unit context measure type' do |id|
      subject(:measure_type) { build(:measure_type, id:) }

      it { is_expected.to be_provides_unit_context }
    end

    it_behaves_like 'a provides unit context measure type', '103'
    it_behaves_like 'a provides unit context measure type', '105'
    it_behaves_like 'a provides unit context measure type', '141'
    it_behaves_like 'a provides unit context measure type', '142'
    it_behaves_like 'a provides unit context measure type', '145'
    it_behaves_like 'a provides unit context measure type', '106'
    it_behaves_like 'a provides unit context measure type', '122'
    it_behaves_like 'a provides unit context measure type', '123'
    it_behaves_like 'a provides unit context measure type', '143'
    it_behaves_like 'a provides unit context measure type', '146'

    context 'when the measure type does not provide unit context' do
      subject(:measure_type) { build(:measure_type, id: '696') }

      it { is_expected.not_to be_provides_unit_context }
    end
  end

  describe '#cds_proofs_of_origin?' do
    context 'when expected type' do
      subject { build(:measure_type, :tariff_preference).cds_proofs_of_origin? }

      it { is_expected.to be true }
    end

    context 'when not expected type' do
      subject { build(:measure_type, :suspension).cds_proofs_of_origin? }

      it { is_expected.to be false }
    end
  end
end
