require 'spec_helper'

RSpec.describe MeasurePresenter do
  subject(:presented_measure) { described_class.new(measure) }

  describe '#has_children_geographical_areas?' do
    let(:measure) { build(:measure, geographical_area: geographical_area) }

    context 'when the measure has a GeographicalArea with children' do
      let(:geographical_area) do
        attributes_for(
          :geographical_area,
          children_geographical_areas: [attributes_for(:geographical_area).stringify_keys],
        ).stringify_keys
      end

      it { is_expected.to be_has_children_geographical_areas }
    end

    context 'when the measure has a GeographicalArea with no children' do
      let(:geographical_area) { attributes_for(:geographical_area).stringify_keys }

      it { is_expected.not_to be_has_children_geographical_areas }
    end
  end

  describe '#children_geographical_areas' do
    let(:measure) { build(:measure, geographical_area: geographical_area) }
    let(:geographical_area) { attributes_for(:geographical_area, geographical_area_id: nil, children_geographical_areas: children_geographical_areas).stringify_keys }

    let(:children_geographical_areas) do
      [
        attributes_for(:geographical_area, id: 'CD').stringify_keys,
        attributes_for(:geographical_area, id: 'AB').stringify_keys,
      ]
    end

    it { expect(presented_measure.children_geographical_areas.map(&:id)).to eq(%w[AB CD]) }
  end

  describe '#has_measure_conditions?' do
    context 'when the measure has measure conditions' do
      let(:measure) { build(:measure, :with_conditions) }

      it { is_expected.to be_has_measure_conditions }
    end

    context 'when the measure has no measure conditions' do
      let(:measure) { build(:measure) }

      it { is_expected.not_to be_has_measure_conditions }
    end
  end

  describe '#has_additional_code?' do
    context 'when the measure has an additional code' do
      let(:measure) { build(:measure, :with_additional_code) }

      it { is_expected.to be_has_additional_code }
    end

    context 'when the measure has no additional code' do
      let(:measure) { build(:measure) }

      it { is_expected.not_to be_has_additional_code }
    end
  end

  describe '#has_measure_footnotes?' do
    context 'when the measure has footnotes' do
      let(:measure) { build(:measure, :with_footnotes) }

      it { is_expected.to be_has_measure_footnotes }
    end

    context 'when the measure has neither footnotes or conditions' do
      let(:measure) { build(:measure) }

      it { is_expected.not_to be_has_measure_footnotes }
    end
  end

  describe '#grouped_measure_conditions' do
    subject(:grouped_conditions) { presented_measure.grouped_measure_conditions }

    let(:measure) do
      build :measure, measure_conditions: [measure_condition]
    end

    let(:measure_condition) do
      attributes_for :measure_condition, condition_code: condition_code,
                                         condition: "#{condition_code}: TEST"
    end

    shared_examples 'its been grouped' do |condition_code, partial_type|
      context "with condition code '#{condition_code}' and partial '#{partial_type}'" do
        let(:condition_code) { condition_code }
        let(:partial_type) { partial_type }

        it 'by condition and partial' do
          expect(grouped_conditions).to \
            have_attributes keys: [
              {
                condition: "#{condition_code}: TEST",
                partial_type: partial_type,
              },
            ]
        end

        it 'into sets of conditions' do
          expect(grouped_conditions.values.first.first.document_code).to \
            eql measure_condition[:document_code]
        end
      end
    end

    it_behaves_like 'its been grouped', 'A', 'document'
    it_behaves_like 'its been grouped', 'B', 'document'
    it_behaves_like 'its been grouped', 'C', 'document'
    it_behaves_like 'its been grouped', 'H', 'document'
    it_behaves_like 'its been grouped', 'Q', 'document'
    it_behaves_like 'its been grouped', 'Y', 'document'
    it_behaves_like 'its been grouped', 'YA', 'document'
    it_behaves_like 'its been grouped', 'YB', 'document'
    it_behaves_like 'its been grouped', 'YC', 'document'
    it_behaves_like 'its been grouped', 'YD', 'document'
    it_behaves_like 'its been grouped', 'Z', 'document'
    it_behaves_like 'its been grouped', 'R', 'ratio'
    it_behaves_like 'its been grouped', 'S', 'ratio'
    it_behaves_like 'its been grouped', 'U', 'ratio'
    it_behaves_like 'its been grouped', 'F', 'ratio_duty'
    it_behaves_like 'its been grouped', 'L', 'ratio_duty'
    it_behaves_like 'its been grouped', 'M', 'ratio_duty'
    it_behaves_like 'its been grouped', 'V', 'ratio_duty'
    it_behaves_like 'its been grouped', 'E', 'quantity'
    it_behaves_like 'its been grouped', 'EA', 'quantity'
    it_behaves_like 'its been grouped', 'EC', 'quantity'
    it_behaves_like 'its been grouped', 'I', 'quantity'
    it_behaves_like 'its been grouped', 'D', 'default'
    it_behaves_like 'its been grouped', 'J', 'default'
    it_behaves_like 'its been grouped', 'X', 'default'
  end
end
