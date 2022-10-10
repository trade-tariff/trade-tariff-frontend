require 'spec_helper'

RSpec.describe PendingQuotaBalanceService do
  describe '#call' do
    subject { described_class.new(commodity.short_code, '1010', Time.zone.today).call }

    let(:start_date) { 5.days.ago }

    let :current_definition do
      attributes_for :definition,
                     balance: '1000.0',
                     validity_start_date: start_date.beginning_of_day.iso8601,
                     validity_end_date: 10.days.from_now.end_of_day.iso8601
    end

    let :previous_definition do
      attributes_for :definition,
                     balance: '2000.0',
                     validity_start_date: (start_date - 10.days).beginning_of_day.iso8601,
                     validity_end_date: (start_date - 1.day).end_of_day.iso8601
    end

    context 'with Commodity' do
      before do
        allow(Commodity).to receive(:find).with(commodity.id, as_of: Time.zone.today)
                                          .and_return commodity
        allow(Commodity).to receive(:find).with(commodity.id, as_of: (start_date - 1.day).to_date)
                                          .and_return previous_commodity
      end

      let :commodity do
        build :commodity, import_measures: [
          attributes_for(:measure, :safeguard),
          attributes_for(
            :measure,
            :quotas,
            order_number: attributes_for(:order_number,
                                         number: '1010',
                                         definition: current_definition),
          ),
        ]
      end

      let :previous_commodity do
        build :commodity,
              goods_nomenclature_item_id: commodity.goods_nomenclature_item_id,
              import_measures: [
                attributes_for(:measure, :safeguard),
                attributes_for(
                  :measure,
                  :quotas,
                  order_number: attributes_for(:order_number,
                                               number: '1010',
                                               definition: previous_definition),
                ),
              ]
      end

      context 'with safeguard measure and inside first twenty days' do
        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'without safeguard measure' do
        let :commodity do
          build :commodity, import_measures: [
            attributes_for(
              :measure,
              :quotas,
              order_number: attributes_for(:order_number,
                                           number: '1010',
                                           definition: current_definition),
            ),
          ]
        end

        it { is_expected.to be_nil }
      end

      context 'when outside of first twenty days' do
        let(:start_date) { 30.days.ago }

        it { is_expected.to be_nil }
      end

      context 'without previous balance' do
        let :previous_commodity do
          build :commodity, goods_nomenclature_item_id: commodity.goods_nomenclature_item_id,
                            import_measures: attributes_for_list(:measure, 1, :safeguard)
        end

        it { is_expected.to be_nil }
      end
    end

    context 'with declarable Heading' do
      subject { described_class.new(heading.short_code, '1010', Time.zone.today).call }

      before do
        allow(Heading).to receive(:find).with(heading.short_code, as_of: Time.zone.today)
                                        .and_return heading
        allow(Heading).to receive(:find).with(heading.short_code, as_of: (start_date - 1.day).to_date)
                                        .and_return previous_heading
      end

      let :heading do
        build :heading, import_measures: [
          attributes_for(:measure, :safeguard),
          attributes_for(
            :measure,
            :quotas,
            order_number: attributes_for(:order_number,
                                         number: '1010',
                                         definition: current_definition),
          ),
        ]
      end

      let :previous_heading do
        build :heading,
              goods_nomenclature_item_id: heading.goods_nomenclature_item_id,
              import_measures: [
                attributes_for(:measure, :safeguard),
                attributes_for(
                  :measure,
                  :quotas,
                  order_number: attributes_for(:order_number,
                                               number: '1010',
                                               definition: previous_definition),
                ),
              ]
      end

      it { is_expected.to eq previous_definition[:balance] }
    end
  end
end
