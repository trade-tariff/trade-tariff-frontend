require 'spec_helper'

RSpec.describe MeasureCollection do
  describe '#for_country' do
    subject(:collection) { described_class.new([italian_measure, russian_measure]) }

    let(:italian_measure) { build(:measure, geographical_area_id: 'IT') }
    let(:russian_measure) { build(:measure, geographical_area_id: 'RU') }

    it { expect(collection.for_country('IT').measures).to eq([italian_measure]) }
  end

  describe '#exclude_supplementary_unit' do
    subject(:collection) { described_class.new([measure, sup_unit_measure]) }

    let(:measure) { build(:measure) }
    let(:sup_unit_measure) { build(:measure, measure_type_description: 'Supplementary unit') }

    it 'excludes measure_type that are supplementary_unit' do
      expect(collection.exclude_supplementary_unit.measures).to eq([measure])
    end
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
    subject(:collection) { described_class.new([import_control_measure, measure]) }

    let(:import_control_measure) { build(:measure, :import_controls) }
    let(:measure) { build(:measure) }

    it { expect(collection.import_controls.measures).to eq([import_control_measure]) }
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
    subject(:collection) { described_class.new([customs_measure, measure]) }

    let(:customs_measure) { build(:measure, :customs_duties) }
    let(:measure) { build(:measure) }

    it { expect(collection.customs_duties.measures).to eq([customs_measure]) }
  end

  describe '#to_a' do
    subject(:collection) { described_class.new([measure]) }

    let(:measure) { build(:measure) }

    it { expect(collection.to_a).to be_kind_of Array }
    it { expect(collection.to_a.first).to be_kind_of MeasurePresenter }
  end

  describe '#present?' do
    context 'when there are measures' do
      subject(:collection) { described_class.new([build(:measure)]) }

      it { is_expected.to be_present }
    end

    context 'when there are no measures' do
      subject(:collection) { described_class.new([]) }

      it { is_expected.not_to be_present }
    end
  end
end
