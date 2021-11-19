require 'spec_helper'

RSpec.describe Measure do
  describe '#relevant_for_country?' do
    it 'returns true when no geographical area is specified' do
      measure = Measure.new(attributes_for(:measure, :eu, geographical_area: { id: 'br',
                                                                               description: 'Brazil' }).stringify_keys)
      expect(
        measure.relevant_for_country?(nil),
      ).to eq true
    end

    it 'returns true if a national measure and geographical area code is equal to 1011' do
      measure = Measure.new(attributes_for(:measure, :national, geographical_area: { id: '1011',
                                                                                     description: 'ERGA OMNES' }).stringify_keys)
      expect(
        measure.relevant_for_country?('br'),
      ).to eq true
    end

    it 'returns false if a national measure and it is an excluded country' do
      measure = Measure.new(attributes_for(:measure, :national, geographical_area: { id: 'lt',
                                                                                     description: 'Lithuania' },
                                                                excluded_countries: [
                                                                  { id: 'lt', description: 'Lithuania', geographical_area_id: 'lt' },
                                                                ]).stringify_keys)
      expect(
        measure.relevant_for_country?('lt'),
      ).to eq false
    end

    it 'returns true if geographical area code matches' do
      measure = Measure.new(attributes_for(:measure, :eu, geographical_area: { id: 'br',
                                                                               description: 'Brazil' }).stringify_keys)
      expect(
        measure.relevant_for_country?('br'),
      ).to eq true
      expect(
        measure.relevant_for_country?('fr'),
      ).to eq false
    end

    it 'returns true if geographical area (group) contains matching code' do
      measure = Measure.new(attributes_for(:measure, :eu, geographical_area: { id: nil,
                                                                               description: 'European Union',
                                                                               children_geographical_areas: [
                                                                                 { id: 'lt', description: 'Lithuania' },
                                                                                 { id: 'fr', description: 'France' },
                                                                               ] }).stringify_keys)
      expect(
        measure.relevant_for_country?('lt'),
      ).to eq true
      expect(
        measure.relevant_for_country?('it'),
      ).to eq false
    end

    it 'returns false if country code is among excluded countries for this measure' do
      measure = Measure.new(attributes_for(:measure, :eu, geographical_area: { id: nil,
                                                                               description: 'European Union',
                                                                               children_geographical_areas: [
                                                                                 { id: 'lt', description: 'Lithuania', geographical_area_id: 'lt' },
                                                                               ] },
                                                          excluded_countries: [
                                                            { id: 'lt', description: 'Lithuania', geographical_area_id: 'lt' },
                                                          ]).stringify_keys)
      expect(
        measure.relevant_for_country?('lt'),
      ).to eq false
    end
  end

  describe '#vat_excise?' do
    subject(:measure) { build(:measure, measure_type: measure_type) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a vat or an excise measure' do
      let(:measure_type_id) { '305' }

      it { is_expected.to be_vat_excise }
    end

    context 'when the measure is not a vat or an excise measure' do
      let(:measure_type_id) { '105' }

      it { is_expected.not_to be_vat_excise }
    end
  end

  describe '#import_controls?' do
    subject(:measure) { build(:measure, measure_type: measure_type) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is an import control measure' do
      let(:measure_type_id) { '277' }

      it { is_expected.to be_import_controls }
    end

    context 'when the measure is not a import control measure' do
      let(:measure_type_id) { '105' }

      it { is_expected.not_to be_import_controls }
    end
  end

  describe '#customs_duties?' do
    subject(:measure) { build(:measure, measure_type: measure_type) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a customs duties measure' do
      let(:measure_type_id) { '103' }

      it { is_expected.to be_customs_duties }
    end

    context 'when the measure is not a customs duties measure' do
      let(:measure_type_id) { '277' }

      it { is_expected.not_to be_customs_duties }
    end
  end

  describe '#quotas?' do
    subject(:measure) { build(:measure, measure_type: measure_type) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a quota measure' do
      let(:measure_type_id) { '122' }

      it { is_expected.to be_quotas }
    end

    context 'when the measure is not a quota measure' do
      let(:measure_type_id) { '277' }

      it { is_expected.not_to be_quotas }
    end
  end

  describe '#trade_remedies?' do
    subject(:measure) { build(:measure, measure_type: measure_type) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a trade remedy measure' do
      let(:measure_type_id) { '551' }

      it { is_expected.to be_trade_remedies }
    end

    context 'when the measure is not a trade remedy measure' do
      let(:measure_type_id) { '277' }

      it { is_expected.not_to be_trade_remedies }
    end
  end

  describe '#import?' do
    context 'when the measure is an import measure' do
      subject(:measure) { build(:measure, :import) }

      it { is_expected.to be_import }
    end

    context 'when the measure is an export measure' do
      subject(:measure) { build(:measure, :export) }

      it { is_expected.not_to be_import }
    end
  end

  describe '#export?' do
    context 'when the measure is an export measure' do
      subject(:measure) { build(:measure, :export) }

      it { is_expected.to be_export }
    end

    context 'when the measure is an import measure' do
      subject(:measure) { build(:measure, :import) }

      it { is_expected.not_to be_export }
    end
  end
end
