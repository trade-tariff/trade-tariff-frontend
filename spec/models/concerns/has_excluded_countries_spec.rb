require 'spec_helper'

RSpec.describe HasExcludedCountries do
  let(:as_of) { Date.current }

  describe '#excluded_country_list' do
    context 'when the excluded_countries include all eu members' do
      subject(:measure) { build(:measure, :with_eu_member_exclusions) }

      let(:expected_list) { 'European Union, Iceland, Liechtenstein, Norway, Switzerland' }

      before do
        eu_member_ids = measure.excluded_countries.map(&:id) - %w[CH IS LI NO EU]
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(eu_member_ids)
        allow(GeographicalArea).to receive(:european_union).with(as_of:).and_return(instance_double(GeographicalArea, description: 'European Union'))
      end

      it { expect(measure.excluded_country_list(as_of:)).to eq(expected_list) }

      it 'returns the same label on repeated calls without mutating excluded countries' do
        expect(
          [measure.excluded_country_list(as_of:), measure.excluded_country_list(as_of:)],
        ).to all(eq(expected_list))
      end
    end

    context 'when the excluded_countries do not include all eu members' do
      subject(:measure) { build(:measure, :with_exclusions) }

      let(:expected_list) { 'Cyprus, Czechia, Switzerland' }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(%w[AT])
      end

      it { expect(measure.excluded_country_list(as_of:)).to eq(expected_list) }
    end

    context 'when there are no excluded countries' do
      subject(:measure) { build(:measure) }

      let(:expected_list) { '' }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(%w[AT])
      end

      it { expect(measure.excluded_country_list(as_of:)).to eq(expected_list) }
    end

    context 'when the EU membership lookup fails' do
      subject(:measure) { build(:measure, :with_exclusions) }

      let(:expected_list) { 'Cyprus, Czechia, Switzerland' }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_raise(Faraday::Error, 'connection refused')
      end

      it { expect(measure.excluded_country_list(as_of:)).to eq(expected_list) }
    end
  end

  describe '#exclusions_include_european_union?' do
    context 'when all EU member IDs are included in excluded countries' do
      subject(:measure) { build(:measure, :with_eu_member_exclusions) }

      before do
        eu_member_ids = measure.excluded_countries.map(&:id) - %w[CH IS LI NO EU]
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(eu_member_ids)
      end

      it { expect(measure.exclusions_include_european_union?(as_of:)).to be true }
    end

    context 'when not all EU member IDs are included in excluded countries' do
      subject(:measure) { build(:measure, :with_exclusions) }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(%w[AT])
      end

      it { expect(measure.exclusions_include_european_union?(as_of:)).to be false }
    end

    context 'when there are no excluded countries' do
      subject(:measure) { build(:measure) }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_return(%w[AT])
      end

      it { expect(measure.exclusions_include_european_union?(as_of:)).to be false }
    end

    context 'when the EU membership lookup fails' do
      subject(:measure) { build(:measure, :with_exclusions) }

      before do
        allow(GeographicalArea).to receive(:eu_members_ids).with(as_of:).and_raise(Faraday::Error, 'connection refused')
      end

      it { expect(measure.exclusions_include_european_union?(as_of:)).to be false }
    end
  end
end
