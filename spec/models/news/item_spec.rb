require 'spec_helper'

RSpec.describe News::Item do
  # This is stubbed for _every_ spec because its in the header menu
  # Reverting it to real implementation for this spec
  before do
    allow(described_class).to receive(:latest_banner).and_call_original
  end

  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :slug }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :precis }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :start_date }
  it { is_expected.to respond_to :end_date }
  it { is_expected.to respond_to :display_style }
  it { is_expected.to respond_to :show_on_xi }
  it { is_expected.to respond_to :show_on_uk }
  it { is_expected.to respond_to :show_on_updates_page }
  it { is_expected.to respond_to :show_on_home_page }
  it { is_expected.to respond_to :collections }

  describe '.latest_for_home_page' do
    subject { described_class.latest_for_home_page }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news/items?service=uk&target=home&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news/items?service=xi&target=home&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end
  end

  describe '.latest_banner' do
    subject { described_class.latest_banner }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news/items?service=uk&target=banner&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1, :banner)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news/items?service=xi&target=banner&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1, :banner)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end

    context 'with failed connection to backend' do
      before do
        stub_api_request('/news/items?service=uk&target=banner&per_page=1', backend: 'uk')
          .to_timeout
      end

      it { is_expected.to be_nil }
    end
  end

  describe '.updates_page' do
    subject { described_class.updates_page }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news/items?per_page=10&service=uk&target=updates', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news/items?&per_page=10&service=xi&target=updates', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with page number' do
      subject { described_class.updates_page(page: 2) }

      before do
        stub_api_request('/news/items?page=2&per_page=10&service=uk&target=updates', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with year filter' do
      subject { described_class.updates_page(year: 2020) }

      before do
        stub_api_request('/news/items?per_page=10&service=uk&target=updates&year=2020', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with collection_id filter' do
      subject { described_class.updates_page(collection_id: 3) }

      before do
        stub_api_request('/news/items?per_page=10&service=uk&target=updates&collection_id=3', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end
  end

  describe '.for_feed' do
    subject { described_class.for_feed }

    include_context 'with UK service'

    before do
      stub_api_request('/news/items?target=updates', backend: 'uk')
        .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
    end

    it { is_expected.to have_attributes length: 2 }
  end

  describe '.cached_latest_banner' do
    subject(:cached_banner) { described_class.cached_latest_banner }

    before { allow(Rails.cache).to receive(:fetch).and_call_original }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news/items?service=uk&target=banner&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1, :banner)
      end

      it 'caches the UK banner' do
        cached_banner

        expect(Rails.cache).to \
          have_received(:fetch)
            .with('news-item-latest-banner-uk-v10', expires_in: 5.minutes)
      end
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news/items?service=xi&target=banner&per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1, :banner)
      end

      it 'caches the XI banner' do
        cached_banner

        expect(Rails.cache).to \
          have_received(:fetch)
            .with('news-item-latest-banner-xi-v10', expires_in: 5.minutes)
      end
    end
  end

  describe '#paragraphs' do
    subject { build(:news_item, content:).paragraphs }

    context 'with single paragraph' do
      let(:content) { 'Hello world' }

      it { is_expected.to eql ['Hello world'] }
    end

    context 'with multiple paragraphs' do
      let(:content) { "Hello\nworld" }

      it { is_expected.to eql %w[Hello world] }
    end

    context 'with trailing whitespace' do
      let(:content) { "Hello\n\n\nworld\n\n\n" }

      it { is_expected.to eql %w[Hello world] }
    end

    context 'with DOS line ending paragraphs' do
      let(:content) { "Hello\r\nworld" }

      it { is_expected.to eql %w[Hello world] }
    end

    context 'with no content' do
      let(:content) { nil }

      it { is_expected.to eql [] }
    end
  end

  describe 'typecasting dates' do
    subject do
      described_class.new start_date: yesterday.to_fs(:db),
                          end_date: tomorrow.to_fs(:db)
    end

    let(:yesterday) { Time.zone.yesterday }
    let(:tomorrow) { Time.zone.tomorrow }

    it { is_expected.to have_attributes start_date: yesterday }
    it { is_expected.to have_attributes end_date: tomorrow }

    context 'with nil end_date' do
      subject { described_class.new start_date: nil, end_date: nil }

      it { is_expected.to have_attributes start_date: nil }
      it { is_expected.to have_attributes end_date: nil }
    end
  end

  context 'with collections' do
    subject { build(:news_item, collection_count: 2).collections }

    it { is_expected.to have_attributes length: 2 }
    it { is_expected.to all be_instance_of News::Collection }
  end

  describe '#precis_with_fallback' do
    subject { news.precis_with_fallback }

    context 'with precis' do
      let(:news) { build :news_item, precis: "first para\n\nsecond para" }

      it { is_expected.to eql "first para\n\nsecond para" }
    end

    context 'without precis' do
      let(:news) { build :news_item, precis: '', content: 'Testing 123' }

      it { is_expected.to eql 'Testing 123' }
    end
  end

  describe '#content_after_precis?' do
    subject { news.content_after_precis? }

    context 'with precis' do
      context 'with content' do
        let(:news) { build :news_item, :with_precis, content: 'something' }

        it { is_expected.to be true }
      end

      context 'without content' do
        let(:news) { build :news_item, :with_precis, content: '' }

        it { is_expected.to be false }
      end
    end

    context 'without precis' do
      context 'with single paragraph content' do
        let(:news) { build :news_item, content: 'first paragraph' }

        it { is_expected.to be false }
      end

      context 'with multiple paragraph content' do
        let(:news) { build :news_item, content: "first paragraph\n\nsecond paragraph" }

        it { is_expected.to be true }
      end
    end
  end

  describe '#content_without_precis' do
    subject { news.content_without_precis }

    context 'with precis' do
      context 'with content' do
        let(:news) { build :news_item, :with_precis, content: 'something' }

        it { is_expected.to eq 'something' }
      end

      context 'without content' do
        let(:news) { build :news_item, :with_precis, content: '' }

        it { is_expected.to be_blank }
      end
    end

    context 'without precis' do
      context 'with single paragraph content' do
        let(:news) { build :news_item, content: 'first paragraph' }

        it { is_expected.to be_blank }
      end

      context 'with multiple paragraph content' do
        let(:news) { build :news_item, content: "first\n\nsecond\n\nthird" }

        it { is_expected.to eq "second\n\nthird" }
      end
    end
  end

  describe '#subheadings' do
    subject { news_item.subheadings }

    let(:news_item) { build :news_item, :with_subheadings }

    it { is_expected.to eql ['Second heading', 'Additional second heading'] }
  end

  describe '#to_param' do
    subject { news_item.to_param }

    context 'with slug' do
      let(:news_item) { build :news_item, slug: 'test-slug' }

      it { is_expected.to eql 'test-slug' }
    end

    context 'with blank slug' do
      let(:news_item) { build :news_item, slug: '' }

      it { is_expected.to eql news_item.id }
    end
  end
end
