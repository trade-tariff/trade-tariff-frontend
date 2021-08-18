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
end
