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
        measure_condition_permutation_groups
        footnotes
        goods_nomenclature
        preference_code
      ]
    end

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end

  it { is_expected.to respond_to :universal_waiver_applies }

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

  describe '#suspension?' do
    subject(:measure) { build(:measure, measure_type:) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a suspension measure' do
      let(:measure_type_id) { '112' }

      it { is_expected.to be_suspension }
    end

    context 'when the measure is not a suspension measure' do
      let(:measure_type_id) { '105' }

      it { is_expected.not_to be_suspension }
    end
  end

  describe '#credibility_check?' do
    subject(:measure) { build(:measure, measure_type:) }

    let(:measure_type) { attributes_for(:measure_type, id: measure_type_id) }

    context 'when the measure is a credibility_check measure' do
      let(:measure_type_id) { '482' }

      it { is_expected.to be_credibility_check }
    end

    context 'when the measure is not a suspension measure' do
      let(:measure_type_id) { '105' }

      it { is_expected.not_to be_credibility_check }
    end
  end

  describe '#excise?' do
    context 'when the measure is an excise measure' do
      subject(:measure) { build(:measure, :excise) }

      it { is_expected.to be_excise }
    end

    context 'when the measure is not an excise measure' do
      let(:measure_type_id) { '105' }

      it { is_expected.not_to be_excise }
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

  describe '#unclassified_import_controls?' do
    context 'when the measure is a potential import control measure' do
      subject(:measure) { build(:measure, :unclassified_import_control) }

      it { is_expected.to be_unclassified_import_controls }
    end

    context 'when the measure is not a import control measure' do
      subject(:measure) { build(:measure, :vat_excise) }

      it { is_expected.not_to be_unclassified_import_controls }
    end
  end

  describe '#third_country_duties?' do
    context 'when the measure is a third country measure' do
      subject(:measure) { build(:measure, :third_country) }

      it { is_expected.to be_third_country_duties }
    end

    context 'when the measure is not a third country measure' do
      subject(:measure) { build(:measure, :vat_excise) }

      it { is_expected.not_to be_third_country_duties }
    end
  end

  describe '#tariff_preferences?' do
    context 'when the measure is a tariff preference' do
      subject(:measure) { build(:measure, :tariff_preference) }

      it { is_expected.to be_tariff_preferences }
    end

    context 'when the measure is not a tariff preference' do
      subject(:measure) { build(:measure, :vat_excise) }

      it { is_expected.not_to be_tariff_preferences }
    end
  end

  describe '#other_customs_duties?' do
    context 'when the measure is an other customs duties measure' do
      subject(:measure) { build(:measure, :other_customs_duties) }

      it { is_expected.to be_other_customs_duties }
    end

    context 'when the measure is not a customs duties measure' do
      subject(:measure) { build(:measure, :vat_excise) }

      it { is_expected.not_to be_other_customs_duties }
    end
  end

  describe '#unclassified_customs_duties?' do
    context 'when the measure is a potential import control measure' do
      subject(:measure) { build(:measure, :unclassified_customs_duties) }

      it { is_expected.to be_unclassified_customs_duties }
    end

    context 'when the measure is not an potential custom duties measure' do
      subject(:measure) { build(:measure, :vat_excise) }

      it { is_expected.not_to be_unclassified_customs_duties }
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

  describe '#measure_conditions_with_guidance' do
    context 'with a condition guidance' do
      subject(:measure) { build :measure, :with_conditions_with_guidance }

      it 'returns measure_conditions with guidance' do
        expect(measure.measure_conditions_with_guidance.size).to eq(1)
      end
    end

    context 'without condition guidances' do
      subject(:measure) { build :measure, :with_conditions }

      it 'returns no measure_conditions with guidance' do
        expect(measure.measure_conditions_with_guidance.size).to eq(0)
      end
    end
  end

  describe '#prohibitive?' do
    context 'with prohibitive measures' do
      subject(:measure) { build(:measure, :prohibitive) }

      it 'returns true' do
        expect(measure).to be_prohibitive
      end
    end

    context 'with conditionally prohibitive measures' do
      subject(:measure) { build(:measure, :prohibitive, :with_additional_code) }

      it 'returns true' do
        expect(measure).to be_conditionally_prohibitive
      end
    end

    context 'without prohibitive measures' do
      subject(:measure) { build(:measure, :with_conditions) }

      it 'returns false when prohibitive' do
        expect(measure.prohibitive?).to eq(false)
      end

      it 'returns false when conditionally prohibitive' do
        expect(measure.conditionally_prohibitive?).to eq(false)
      end
    end
  end

  describe '#residual?' do
    context 'with residual measure' do
      subject(:measure) { build(:measure, :residual) }

      it 'returns true' do
        expect(measure).to be_residual
      end
    end

    context 'without residual measure' do
      subject(:measure) { build(:measure) }

      it 'returns false' do
        expect(measure).not_to be_residual
      end
    end
  end

  describe '#safeguard?' do
    context 'with safeguard measure' do
      subject { build :measure, :safeguard }

      it { is_expected.to be_safeguard }
    end

    context 'with non-safeguard measure' do
      subject { build :measure }

      it { is_expected.not_to be_safeguard }
    end
  end
end
