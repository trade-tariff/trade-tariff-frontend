require 'spec_helper'

RSpec.describe HasExcludedCountries do
  describe '#excluded_country_list', vcr: { cassette_name: 'geographical_areas#1013' } do
    context 'when the excluded_countries include all eu members' do
      subject(:measure) { build(:measure, :with_eu_member_exclusions) }

      let(:expected_list) { 'European Union, Switzerland, Iceland, Liechtenstein, Norway' }

      it { expect(measure.excluded_country_list).to eq(expected_list) }
    end

    context 'when the excluded_countries do not include all eu members' do
      subject(:measure) { build(:measure, :with_exclusions) }

      let(:expected_list) { 'Switzerland, Cyprus, Czechia' }

      it { expect(measure.excluded_country_list).to eq(expected_list) }
    end

    context 'when there are no excluded countries' do
      subject(:measure) { build(:measure) }

      let(:expected_list) { '' }

      it { expect(measure.excluded_country_list).to eq(expected_list) }
    end

    context 'when excluded countries are not in alphabetical order' do
      subject(:measure) { build(:measure) }

      before do
        allow(measure).to receive(:exclusions_include_european_union?).and_return(false)
        allow(measure).to receive(:excluded_countries).and_return(
          [
            instance_double(GeographicalArea, description: 'Switzerland'),
            instance_double(GeographicalArea, description: 'Cyprus'),
            instance_double(GeographicalArea, description: 'Czechia'),
          ],
        )
      end

      it 'sorts the country descriptions alphabetically' do
        expect(measure.excluded_country_list).to eq('Cyprus, Czechia, Switzerland')
      end
    end
  end

  describe '#exclusions_include_european_union?' do
    context 'when all EU member IDs are included in excluded countries' do
      subject(:measure) { build(:measure, :with_eu_member_exclusions) }

      it { expect(measure.exclusions_include_european_union?).to be true }
    end

    context 'when not all EU member IDs are included in excluded countries' do
      subject(:measure) { build(:measure, :with_exclusions) }

      it { expect(measure.exclusions_include_european_union?).to be false }
    end

    context 'when there are no excluded countries' do
      subject(:measure) { build(:measure) }

      it { expect(measure.exclusions_include_european_union?).to be false }
    end
  end
end
