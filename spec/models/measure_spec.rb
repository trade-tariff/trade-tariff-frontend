require 'spec_helper'

RSpec.describe Measure do
  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        geographical_area
        legal_acts
        measure_type
        suspension_legal_act
        additional_code
        order_number
        duty_expression
        excluded_countries
        measure_components
        measure_conditions
        footnotes
        goods_nomenclature
      ]
    end

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end

  describe '#relevant_for_country?' do
    context 'when the area is not present' do
      subject(:measure) { build(:measure, :eu, geographical_area: { id: 'br', description: 'Brazil' }) }

      it { expect(measure.relevant_for_country?(nil)).to eq true }
    end

    context 'when the measure is a national measure that is erga omnes' do
      subject(:measure) { build(:measure, :national, :erga_omnes) }

      it { expect(measure.relevant_for_country?('br')).to eq true }
    end

    context 'when the area is an excluded geographical area' do
      subject(:measure) do
        build(:measure, geographical_area: { id: 'lt',
                                             description: 'Lithuania' },
                        excluded_countries: [
                          { id: 'lt', description: 'Lithuania', geographical_area_id: 'lt' },
                        ])
      end

      it { expect(measure.relevant_for_country?('lt')).to eq false }
    end

    context 'when an exact match on the geographical_area_id' do
      subject(:measure) { build(:measure, :eu, geographical_area: { id: 'br' }) }

      it { expect(measure.relevant_for_country?('br')).to eq true }
    end

    context 'when a group match on the geographical_area_id' do
      subject(:measure) do
        build(:measure, :eu, geographical_area: { id: nil,
                                                  description: 'European Union',
                                                  children_geographical_areas: [
                                                    { id: 'lt', description: 'Lithuania' },
                                                    { id: 'fr', description: 'France' },
                                                  ] })
      end

      it { expect(measure.relevant_for_country?('lt')).to eq true }
      it { expect(measure.relevant_for_country?('it')).to eq false }
    end
  end

  describe '#vat_excise?' do
    subject(:measure) { build(:measure, measure_type:) }

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
    subject(:measure) { build(:measure, measure_type:) }

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
    subject(:measure) { build(:measure, measure_type:) }

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
    subject(:measure) { build(:measure, measure_type:) }

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
    subject(:measure) { build(:measure, measure_type:) }

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
  end
end
