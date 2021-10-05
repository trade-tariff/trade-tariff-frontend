require 'spec_helper'

RSpec.describe SearchSuggestion do
  describe '.all', vcr: { cassette_name: 'search#suggestions', allow_playback_repeats: true } do
    let(:suggestions) { SearchSuggestion.all }

    it 'fetches suggestions from the API' do
      expect(suggestions).to be_kind_of Array
      expect(suggestions).not_to be_blank
    end

    it 'sorts suggestions by value' do
      expect(suggestions.first.value).to be < suggestions.last.value
    end
  end

  describe '.start_with', vcr: { cassette_name: 'search#suggestions', allow_playback_repeats: true } do
    it 'invokes .cached_suggestions method' do
      expect(described_class).to receive(:cached_suggestions).and_return([])
      described_class.start_with('123')
    end

    it 'returns suggestions filtered by value' do
      values = SearchSuggestion.all
      expect(described_class.start_with(values[0].value.first(4)).map(&:value)).to include(values[0].value)
    end

    it 'returns less then 10 values' do
      expect(described_class.start_with('80').length).to be <= 10
    end
  end
end
