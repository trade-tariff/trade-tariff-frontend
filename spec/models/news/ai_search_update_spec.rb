require 'spec_helper'

RSpec.describe News::AiSearchUpdate do
  describe '.merge' do
    subject(:listed) do
      described_class.merge(
        news_items,
        enabled:,
        year:,
        collection:,
        collection_id:,
        page:,
      )
    end

    let(:enabled) { true }
    let(:year) { nil }
    let(:collection) { nil }
    let(:collection_id) { nil }
    let(:page) { 1 }
    let(:service_updates) { build(:news_collection, name: 'Service updates', slug: 'service_updates') }
    let(:other_collection) { build(:news_collection, name: 'Tariff notices', slug: 'tariff_notices') }

    def item_on(date)
      build(:news_item, start_date: date)
    end

    def page_for(items, total_count:)
      Kaminari.paginate_array(items, total_count:).page(1).per(10)
    end

    context 'when the feature is disabled' do
      let(:enabled) { false }
      let(:news_items) { page_for([item_on(Date.new(2026, 7, 24))], total_count: 1) }

      it { is_expected.to eq(news_items.to_a) }
    end

    context 'with older service updates on the first page' do
      let(:news_items) { page_for([item_on(Date.new(2026, 7, 24))], total_count: 1) }

      it 'places the update first', :aggregate_failures do
        expect(listed.first).to be_ai_search_update
        expect(listed.map { |item| item.start_date.to_date }).to eq(
          [Date.new(2026, 9, 9), Date.new(2026, 7, 24)],
        )
      end
    end

    context 'with newer items on the first page' do
      let(:news_items) do
        page_for(
          [
            item_on(Date.new(2026, 9, 16)),
            item_on(Date.new(2026, 9, 10)),
          ],
          total_count: 20,
        )
      end

      it { is_expected.not_to include(a_kind_of(described_class)) }
    end

    context 'when the date falls inside the current page' do
      let(:page) { 2 }
      let(:news_items) do
        page_for(
          [
            item_on(Date.new(2026, 9, 10)),
            item_on(Date.new(2026, 9, 8)),
          ],
          total_count: 20,
        )
      end

      it 'inserts the update in date order' do
        expect(listed.map { |item| item.start_date.to_date }).to eq(
          [Date.new(2026, 9, 10), Date.new(2026, 9, 9), Date.new(2026, 9, 8)],
        )
      end
    end

    context 'when the date falls between pages' do
      let(:page) { 2 }
      let(:news_items) do
        page_for(
          [item_on(Date.new(2026, 9, 8))],
          total_count: 20,
        )
      end

      it 'places the update at the start of the later page' do
        expect(listed.first).to be_ai_search_update
      end
    end

    context 'with the 2026 year filter' do
      let(:year) { 2026 }
      let(:news_items) { page_for([item_on(Date.new(2026, 7, 24))], total_count: 1) }

      it { is_expected.to include(a_kind_of(described_class)) }
    end

    context 'with another year filter' do
      let(:year) { 2025 }
      let(:news_items) { page_for([item_on(Date.new(2025, 7, 24))], total_count: 1) }

      it { is_expected.not_to include(a_kind_of(described_class)) }
    end

    context 'with the service updates collection' do
      let(:collection) { service_updates }
      let(:collection_id) { 'service_updates' }
      let(:news_items) { page_for([item_on(Date.new(2026, 7, 24))], total_count: 1) }

      it { is_expected.to include(a_kind_of(described_class)) }
    end

    context 'with another collection' do
      let(:collection) { other_collection }
      let(:collection_id) { 'tariff_notices' }
      let(:news_items) { page_for([item_on(Date.new(2026, 7, 24))], total_count: 1) }

      it { is_expected.not_to include(a_kind_of(described_class)) }
    end
  end
end
