require 'spec_helper'

RSpec.describe ValidityPeriod do
  it { is_expected.to respond_to :goods_nomenclature_item_id }
  it { is_expected.to respond_to :validity_start_date }
  it { is_expected.to respond_to :validity_end_date }

  describe '#start_date' do
    context 'when the ValidityPeriod has a validity_start_date' do
      subject(:start_date) { build(:validity_period, :with_start_date).start_date }

      it { is_expected.to eq('1999-01-01T00:00:00.000Z'.to_date) }
      it { is_expected.to be_a(Date) }
    end

    context 'when the ValidityPeriod has no validity_start_date' do
      subject(:start_date) { build(:validity_period, :without_start_date).start_date }

      it { is_expected.to be_nil }
    end
  end

  describe '#end_date' do
    context 'when the ValidityPeriod has a validity_end_date' do
      subject(:end_date) { build(:validity_period, :with_end_date).end_date }

      it { is_expected.to eq('1999-01-01T00:00:00.000Z'.to_date) }
      it { is_expected.to be_a(Date) }
    end

    context 'when the ValidityPeriod has no validity_end_date' do
      subject(:end_date) { build(:validity_period, :without_end_date).end_date }

      it { is_expected.to be_nil }
    end
  end

  describe '.all' do
    context 'with commodity' do
      subject { described_class.all Commodity, '0101012345' }

      before do
        stub_api_request('/commodities/0101012345/validity_periods')
          .to_return jsonapi_response(:validity_periods, validity_periods)
      end

      let(:commodity) do
        build :commodity, goods_nomenclature_item_id: '0101012345'
      end

      let(:validity_periods) do
        attributes_for_list(:validity_period, 2, goods_nomenclature: commodity)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with heading' do
      subject { described_class.all Heading, '0101' }

      before do
        stub_api_request('/headings/0101/validity_periods')
          .to_return jsonapi_response(:validity_periods, validity_periods)
      end

      let(:heading) do
        build :heading, goods_nomenclature_item_id: '0101'
      end

      let(:validity_periods) do
        attributes_for_list(:validity_period, 3, goods_nomenclature: heading)
      end

      it { is_expected.to have_attributes length: 3 }
    end

    context 'with extra params' do
      subject { described_class.all Commodity, '0101012345', page: 3 }

      before do
        stub_api_request('/commodities/0101012345/validity_periods?page=3')
          .to_return jsonapi_response(:validity_periods, validity_periods)
      end

      let(:commodity) do
        build :commodity, goods_nomenclature_item_id: '0101012345'
      end

      let(:validity_periods) do
        attributes_for_list(:validity_period, 1, goods_nomenclature: commodity)
      end

      it { is_expected.to have_attributes length: 1 }
    end
  end
end
