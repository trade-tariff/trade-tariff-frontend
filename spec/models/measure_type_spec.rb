require 'spec_helper'

RSpec.describe MeasureType do
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
end
