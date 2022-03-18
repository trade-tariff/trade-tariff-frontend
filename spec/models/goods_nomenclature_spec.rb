require 'spec_helper'

RSpec.describe GoodsNomenclature do
  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        section
        headings
        section
        chapter
        footnotes
        import_measures
        export_measures
        heading
        overview_measures
        ancestors
        section
        chapter
        footnotes
        import_measures
        export_measures
        commodities
        children
        section
        chapter
        heading
        footnotes
        commodities
      ]
    end

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end

  describe '#validity_start_date=' do
    let(:goods_nomenclature) { described_class.new }

    context 'with passed date present' do
      it 'sets date' do
        goods_nomenclature.validity_start_date = Time.zone.today

        expect(goods_nomenclature.validity_start_date).to eq Time.zone.today.to_date
      end
    end

    context 'with blank passed date' do
      it 'does not set validity end date' do
        goods_nomenclature.validity_start_date = nil

        expect(goods_nomenclature.validity_start_date).to be_blank
      end
    end
  end

  describe '#validity_end_date=' do
    let(:goods_nomenclature) { described_class.new }

    context 'with passed date present' do
      it 'sets date' do
        goods_nomenclature.validity_end_date = Time.zone.today

        expect(goods_nomenclature.validity_end_date).to eq Time.zone.today.to_date
      end
    end

    context 'with blank passed date' do
      it 'does not set validity end date' do
        goods_nomenclature.validity_end_date = nil

        expect(goods_nomenclature.validity_end_date).to be_blank
      end
    end
  end

  describe '#validity_start_date' do
    context 'with the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_start_date: Time.zone.today)
      end

      it 'returns instance of Date' do
        expect(goods_nomenclature.validity_start_date).to be_kind_of Date
      end

      it 'returns parsed date' do
        expect(goods_nomenclature.validity_start_date).to eq Time.zone.today.to_date
      end
    end

    context 'without the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_start_date: nil)
      end

      it 'returns NullObject' do
        expect(goods_nomenclature.validity_start_date).to be_kind_of NullObject
      end
    end
  end

  describe '#validity_end_date' do
    context 'with the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_end_date: Time.zone.today)
      end

      it 'returns instance of Date' do
        expect(goods_nomenclature.validity_end_date).to be_kind_of Date
      end

      it 'returns parsed date' do
        expect(goods_nomenclature.validity_end_date).to eq Time.zone.today.to_date
      end
    end

    context 'without the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_end_date: nil)
      end

      it 'returns NullObject' do
        expect(goods_nomenclature.validity_end_date).to be_kind_of NullObject
      end
    end
  end

  describe '#rules_of_origin' do
    before do
      # Needed because goods nomenclature isn't declarable but #rules_of_origin
      # short circuits for any non-declarable nomenclatures
      allow(goods_nomenclature).to receive(:declarable?).and_return true
    end

    let(:goods_nomenclature) { build(:goods_nomenclature) }

    context 'without country param' do
      it 'will raise an exception' do
        expect { goods_nomenclature.rules_of_origin }.to raise_exception ArgumentError
      end
    end

    context 'with country param' do
      subject(:rules) { goods_nomenclature.rules_of_origin('FR') }

      before do
        allow(RulesOfOrigin::Scheme).to receive(:all)
          .with(goods_nomenclature.code, 'FR')
          .and_return([])
      end

      it 'will chain chain to RulesOfOrigin::Scheme' do
        rules # trigger call

        expect(RulesOfOrigin::Scheme).to have_received(:all)
          .with(goods_nomenclature.code, 'FR')
      end
    end

    context 'with country param and additional params' do
      subject(:rules) do
        goods_nomenclature.rules_of_origin('FR', page: 1)
      end

      before do
        allow(RulesOfOrigin::Scheme).to receive(:all)
          .with(goods_nomenclature.code, 'FR', page: 1)
          .and_return([])
      end

      it 'will chain chain to RulesOfOrigin::Scheme' do
        rules # trigger call

        expect(RulesOfOrigin::Scheme).to have_received(:all)
          .with(goods_nomenclature.code, 'FR', page: 1)
      end
    end
  end

  describe '#rules_of_origin_rules' do
    subject { goods_nomenclature.rules_of_origin_rules(country_code) }

    before do
      allow(goods_nomenclature).to \
        receive(:rules_of_origin).with(country_code).and_return schemes
    end

    let(:goods_nomenclature) { build :goods_nomenclature }
    let(:schemes) { build_list :rules_of_origin_scheme, 2 }
    let(:country_code) { schemes.first.countries.first }

    it { is_expected.to have_attributes length: 6 }
    it { is_expected.to eql schemes.map(&:rules).flatten }
  end
end
