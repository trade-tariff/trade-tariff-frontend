require 'spec_helper'

RSpec.describe ValidityPeriod do
  it { is_expected.to respond_to :goods_nomenclature_item_id }
  it { is_expected.to respond_to :validity_start_date }
  it { is_expected.to respond_to :validity_end_date }

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

  describe 'date handling' do
    shared_examples 'a date attribute' do
      context 'with xml string' do
        let(:date) { Time.zone.now.iso8601 }

        it { is_expected.to eql Time.zone.today }
      end

      context 'with long textual string' do
        let(:date) { Time.zone.today.to_formatted_s :long }

        it { is_expected.to eql Time.zone.today }
      end

      context 'with short textual string' do
        let(:date) { Time.zone.today.to_formatted_s :short }

        it { is_expected.to eql Time.zone.today }
      end

      context 'with Date object' do
        let(:date) { Time.zone.yesterday }

        it { is_expected.to eql Time.zone.yesterday }
      end

      context 'with Time object' do
        let(:date) { 1.day.ago }

        it { is_expected.to eql Time.zone.yesterday }
      end

      context 'with DateTime object' do
        # rubocop:disable Style/DateTime
        let(:date) { DateTime.now }
        # rubocop:enable Style/DateTime

        it { is_expected.to eql Time.zone.today }
      end

      context 'with nil' do
        let(:date) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe '#validity_start_date=' do
      subject { instance.validity_start_date }

      let(:instance) { described_class.new(validity_start_date: date) }

      it_behaves_like 'a date attribute'
    end

    describe '#validity_end_date=' do
      subject { instance.validity_end_date }

      let(:instance) { described_class.new(validity_end_date: date) }

      it_behaves_like 'a date attribute'
    end
  end
end
