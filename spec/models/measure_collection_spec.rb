require 'spec_helper'

RSpec.describe MeasureCollection do
  describe '#for_country' do
    subject(:collection) { described_class.new([italian_measure, russian_measure]) }

    let(:italian_measure) { build(:measure, geographical_area_id: 'IT') }
    let(:russian_measure) { build(:measure, geographical_area_id: 'RU') }

    it { expect(collection.for_country('IT').measures).to eq([italian_measure]) }
  end

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
    subject(:collection) { described_class.new([vat_measure, measure]) }

    let(:vat_measure) { build(:measure, :vat) }
    let(:measure) { build(:measure) }

    it { expect(collection.vat.measures).to eq([vat_measure]) }
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
end
