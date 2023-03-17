require 'spec_helper'

RSpec.describe MeasureCollection do
  describe '#without_supplementary_unit' do
    subject(:collection) { described_class.new([measure, sup_unit_measure]) }

    let(:measure) { build(:measure) }
    let(:sup_unit_measure) { build(:measure, :import_export_supplementary) }

    it { expect(collection.without_supplementary_unit.measures).to eq([measure]) }
  end

  describe '#without_excluded' do
    subject(:collection) { described_class.new([measure, excluded_measure]) }

    let(:measure) { build(:measure) }
    let(:excluded_measure) { build(:measure, :excluded) }

    it { expect(collection.without_excluded.measures).to eq([measure]) }
  end

  describe '#vat' do
    subject(:collection) { described_class.new([vat_measure_reduced, measure, vat_measure_standard, vat_measure_zero]) }

    let(:vat_measure_standard) { build(:measure, :vat_standard) }
    let(:vat_measure_zero) { build(:measure, :vat_zero) }
    let(:vat_measure_reduced) { build(:measure, :vat_reduced) }

    let(:measure) { build(:measure) }

    it { expect(collection.vat.measures).to eq([vat_measure_standard, vat_measure_reduced, vat_measure_zero]) }
  end

  describe '#vat_erga_omnes' do
    subject(:collection) { described_class.new([vat_measure_reduced, measure, vat_measure_standard_erga_omnes, vat_measure_zero]) }

    let(:vat_measure_standard_erga_omnes) { build(:measure, :vat_standard, :erga_omnes) }
    let(:vat_measure_zero) { build(:measure, :vat_zero) }
    let(:vat_measure_reduced) { build(:measure, :vat_reduced) }

    let(:measure) { build(:measure) }

    it { expect(collection.vat_erga_omnes.measures).to eq([vat_measure_standard_erga_omnes]) }
  end

  describe '#excise' do
    subject(:collection) { described_class.new([excise_measure, measure]) }

    let(:excise_measure) { build(:measure, :excise) }
    let(:measure) { build(:measure) }

    it { expect(collection.excise.measures).to eq([excise_measure]) }
  end

  describe '#excise?' do
    context 'when the measure is excise' do
      subject(:collection) { described_class.new([excise_measure, measure]) }

      let(:excise_measure) { build(:measure, :excise) }
      let(:measure) { build(:measure) }

      it { is_expected.to be_excise }
    end

    context 'when the measure is not excise' do
      subject(:collection_vat) { described_class.new([vat_measure, measure]) }

      let(:vat_measure) { build(:measure, :vat) }
      let(:measure) { build(:measure) }

      it { is_expected.not_to be_excise }
    end
  end

  describe '#measure_with_highest_vat_rate' do
    subject(:collection) { described_class.new([vat_measure_zero, vat_measure_standard, vat_measure_reduced]) }

    let(:vat_measure_standard) { build(:measure, :vat_standard) }
    let(:vat_measure_zero) { build(:measure, :vat_zero) }
    let(:vat_measure_reduced) { build(:measure, :vat_reduced) }

    it { expect(collection.measure_with_highest_vat_rate).to eq(vat_measure_standard) }
  end

  describe '#measure_with_highest_vat_rate_erga_omnes' do
    subject(:collection) { described_class.new([vat_measure_zero, vat_measure_standard_erga_omnes, vat_measure_reduced]) }

    let(:vat_measure_standard_erga_omnes) { build(:measure, :vat_standard, :erga_omnes) }
    let(:vat_measure_zero) { build(:measure, :vat_zero) }
    let(:vat_measure_reduced) { build(:measure, :vat_reduced) }

    it { expect(collection.measure_with_highest_vat_rate_erga_omnes).to eq(vat_measure_standard_erga_omnes) }
  end

  describe '#national' do
    subject(:collection) { described_class.new([national_measure, eu_measure]) }

    let(:national_measure) { build(:measure, :national) }
    let(:eu_measure) { build(:measure, :eu) }

    it { expect(collection.national.measures).to eq([national_measure]) }
  end

  describe '#vat_excise' do
    subject(:collection) { described_class.new([vat_excise_measure, measure]) }

    let(:vat_excise_measure) { build(:measure, :vat_excise) }
    let(:measure) { build(:measure) }

    it { expect(collection.vat_excise.measures).to eq([vat_excise_measure]) }
  end

  describe '#suspension' do
    subject(:collection) { described_class.new([suspension_measure, measure]) }

    let(:suspension_measure) { build(:measure, :suspension) }
    let(:measure) { build(:measure) }

    it { expect(collection.suspensions.measures).to eq([suspension_measure]) }
  end

  describe '#credibility_checks' do
    subject(:collection) { described_class.new([credibility_check_measure, measure]) }

    let(:credibility_check_measure) { build(:measure, :credibility_check) }
    let(:measure) { build(:measure) }

    it { expect(collection.credibility_checks.measures).to eq([credibility_check_measure]) }
  end

  describe '#import_controls' do
    subject(:collection) { described_class.new([unclassified_import_control_measure, import_control_measure, measure]) }

    let(:unclassified_import_control_measure) { build(:measure, :unclassified_import_control) }
    let(:import_control_measure) { build(:measure, :import_controls) }
    let(:measure) { build(:measure, :vat_excise) }

    it { expect(collection.import_controls.measures).to eq([import_control_measure, unclassified_import_control_measure]) }
  end

  describe '#trade_remedies' do
    subject(:collection) { described_class.new([trade_remedy_measure, measure]) }

    let(:trade_remedy_measure) { build(:measure, :trade_remedies) }
    let(:measure) { build(:measure) }

    it { expect(collection.trade_remedies.measures).to eq([trade_remedy_measure]) }
  end

  describe '#quotas' do
    subject(:collection) { described_class.new([quota_measure, measure]) }

    let(:quota_measure) { build(:measure, :quotas) }
    let(:measure) { build(:measure) }

    it { expect(collection.quotas.measures).to eq([quota_measure]) }
  end

  describe '#customs_duties' do
    subject(:collection) { described_class.new([third_country_measure, unclassified_customs_measure, other_customs_duties_measure, tariff_preference_measure, vat_excise_measure]) }

    let(:third_country_measure) { build(:measure, :third_country) }
    let(:tariff_preference_measure) { build(:measure, :tariff_preference) }
    let(:other_customs_duties_measure) { build(:measure, :other_customs_duties) }
    let(:unclassified_customs_measure) { build(:measure, :unclassified_customs_duties) }
    let(:vat_excise_measure) { build(:measure, :vat_excise) }

    it { expect(collection.customs_duties.measures).to eq([third_country_measure, tariff_preference_measure, other_customs_duties_measure, unclassified_customs_measure]) }
  end

  describe '#find_by_quota_order_number' do
    subject :measure do
      described_class.new(measures).find_by_quota_order_number '12345'
    end

    let(:measures) { [vat_measure, quota_measure] }
    let(:vat_measure) { build :measure, :vat }
    let(:quota_measure) { build :measure, :quotas, order_number: }
    let(:order_number) { attributes_for :order_number, number: '12345' }

    context 'with non-quota measures' do
      let(:measures) { [vat_measure] }

      it { is_expected.to be_nil }
    end

    context 'with matching quota measure' do
      it { is_expected.to eq quota_measure }
    end

    context 'without matching quota measure' do
      let(:order_number) { attributes_for :order_number, number: '67890' }

      it { is_expected.to be_nil }
    end
  end

  describe '#erga_omnes' do
    subject(:collection) { described_class.new([erga_omnes_measure, measure]) }

    let(:erga_omnes_measure) { build(:measure, :erga_omnes) }
    let(:measure) { build(:measure) }

    it { expect(collection.erga_omnes.measures).to eq([erga_omnes_measure]) }
  end
end
