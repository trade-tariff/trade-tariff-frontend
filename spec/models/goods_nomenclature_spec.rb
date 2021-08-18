require 'spec_helper'

describe GoodsNomenclature do
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

  describe '#product_specific_rules' do
    let(:goods_nomenclature) { build(:goods_nomenclature) }

    context 'without country param' do
      it 'will raise an exception' do
        expect { goods_nomenclature.rules }.to raise_exception ArgumentError
      end
    end

    context 'with country param' do
      subject(:rules) { goods_nomenclature.rules('FR') }

      before do
        allow(ProductSpecificRule).to receive(:all)
          .with(goods_nomenclature.code, 'FR')
          .and_return([])
      end

      it 'will chain chain to ProductSpecificRule' do
        rules # trigger call

        expect(ProductSpecificRule).to have_received(:all)
          .with(goods_nomenclature.code, 'FR')
      end
    end

    context 'with country param and additional params' do
      subject(:rules) { goods_nomenclature.rules('FR', page: 1) }

      before do
        allow(ProductSpecificRule).to receive(:all)
          .with(goods_nomenclature.code, 'FR', page: 1)
          .and_return([])
      end

      it 'will chain chain to ProductSpecificRule' do
        rules # trigger call

        expect(ProductSpecificRule).to have_received(:all)
          .with(goods_nomenclature.code, 'FR', page: 1)
      end
    end
  end
end
