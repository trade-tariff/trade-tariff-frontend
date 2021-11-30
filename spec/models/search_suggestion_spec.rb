require 'spec_helper'

RSpec.describe SearchSuggestion do
  describe '.all', vcr: { cassette_name: 'search#suggestions', allow_playback_repeats: true } do
    subject(:suggestions) { described_class.all }

    it { is_expected.to be_kind_of Array }
    it { is_expected.not_to be_empty }

    it 'sorts suggestions by value' do
      expect(suggestions.first.value).to be < suggestions.last.value
    end
  end

  describe '.start_with', vcr: { cassette_name: 'search#suggestions', allow_playback_repeats: true } do
    before { allow(Rails.cache).to receive(:write_multi).and_call_original }

    it 'utilises Rails cache' do
      described_class.start_with('123')
      expect(Rails.cache).to have_received(:write_multi)
    end

    it 'returns suggestions filtered by value' do
      values = described_class.all
      expect(described_class.start_with(values[0].value.first(4)).map(&:value)).to include(values[0].value)
    end

    it 'returns less then 10 values' do
      expect(described_class.start_with('80').length).to be <= 10
    end
  end
end
