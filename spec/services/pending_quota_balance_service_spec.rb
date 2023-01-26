require 'spec_helper'

RSpec.describe PendingQuotaBalanceService do
  describe '#call' do
    subject :pending_balance do
      described_class.new(commodity.short_code, '1010', Time.zone.today).call
    end

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

      context 'with the definition in the quotas first quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 7) }

        it { is_expected.to be_nil }
      end

      context 'with the definition in the quotas second quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 9) }

        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'with the definition in the quotas third quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 1) }

        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'with the definition in the quotas fourth quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 4) }

        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'with the definition in before hmrc started managing pending balances' do
        let(:start_date) { Date.current.change(year: 2022, day: 30, month: 6) }

        it { is_expected.to be_nil }
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

      context 'without previous balance' do
        let :previous_commodity do
          build :commodity, goods_nomenclature_item_id: commodity.goods_nomenclature_item_id,
                            import_measures: attributes_for_list(:measure, 1, :safeguard)
        end

        it { is_expected.to be_nil }
      end

      context 'without current declarable' do
        before do
          allow(Commodity).to receive(:find).with(commodity.id, as_of: Time.zone.today)
                                            .and_raise(Faraday::ResourceNotFound, 'unknown')
        end

        it { expect { pending_balance }.to raise_exception Faraday::ResourceNotFound }
      end

      context 'without previous declarable' do
        before do
          allow(Commodity).to receive(:find).with(commodity.id, as_of: (start_date - 1.day).to_date)
                                            .and_raise(Faraday::ResourceNotFound, 'unknown')
        end

        it { is_expected.to be_nil }
      end

      context 'without current definition' do
        let(:current_definition) { nil }

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

      context 'with the definition in the quotas first quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 7) }

        it { is_expected.to be_nil }
      end

      context 'with the definition in the quotas second quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 9) }

        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'with the definition in the quotas third quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 1) }

        it { is_expected.to eq previous_definition[:balance] }
      end

      context 'with the definition in the quotas fourth quarter' do
        let(:start_date) { Date.current.change(day: 1, month: 4) }

        it { is_expected.to eq previous_definition[:balance] }
      end
    end

    context 'with no import measures' do
      subject { described_class.new(heading.short_code, '1010', Time.zone.today).call }

      let(:heading) { build :heading }

      before do
        allow(Heading).to receive(:find).with(heading.short_code, as_of: Time.zone.today)
                                        .and_return heading
      end

      it { is_expected.to be nil }
    end
  end
end
