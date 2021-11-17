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
end
