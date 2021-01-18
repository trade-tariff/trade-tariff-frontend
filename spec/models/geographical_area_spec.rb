require 'spec_helper'

describe GeographicalArea do
  describe '.all', vcr: { cassette_name: 'geographical_areas#countries' } do
    let(:countries) { GeographicalArea.countries }

    it 'fetches geographical areas that are countries from the API' do
      expect(countries).to be_kind_of Array
      expect(countries).not_to be_blank
    end

    it 'sorts countries by id' do
      expect(countries.first.id).to be < countries.second.id
    end

    it 'removes excluded countries (United Kingdom)' do
      expect(
        countries.detect { |c| c.id == 'GB' },
      ).to be_blank
    end
  end

  describe '.by_long_description', vcr: { cassette_name: 'geographical_areas#countries' } do
    let(:by_long_desc) { GeographicalArea.by_long_description('in') }

    it 'returns an array' do
      expect(by_long_desc).to be_a(Array)
    end

    it 'filters areas by id and description' do
      expect(by_long_desc.detect { |c| c.id == 'BR' }).to be_blank
    end

    # TODO: need to fix countryies ordering
    it 'sorts countries by id and description' do
      expect(by_long_desc[0].id).to eq('IN')
      expect(by_long_desc[1].id).to eq('ID')
      expect(by_long_desc[2].id).to eq('FI')
    end
  end
end
