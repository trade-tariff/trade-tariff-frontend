require 'spec_helper'

RSpec.describe NewsItem do
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :start_date }
  it { is_expected.to respond_to :end_date }
  it { is_expected.to respond_to :display_style }
  it { is_expected.to respond_to :show_on_xi }
  it { is_expected.to respond_to :show_on_uk }
  it { is_expected.to respond_to :show_on_updates_page }
  it { is_expected.to respond_to :show_on_home_page }

  describe '.latest_for_home_page' do
    subject { described_class.latest_for_home_page }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news_items/uk/home?per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news_items/xi/home?per_page=1', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 1)
      end

      it { is_expected.to have_attributes title: /News item \d+/ }
    end
  end

  describe '.updates_page' do
    subject { described_class.updates_page }

    context 'with UK service' do
      include_context 'with UK service'

      before do
        stub_api_request('/news_items/uk/updates', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with XI service' do
      include_context 'with XI service'

      before do
        stub_api_request('/news_items/xi/updates', backend: 'uk')
          .to_return jsonapi_response :news_item, attributes_for_list(:news_item, 2)
      end

      it { is_expected.to have_attributes length: 2 }
    end
  end

  describe '#paragraphs' do
    subject { build(:news_item, content: content).paragraphs }

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
      described_class.new start_date: yesterday.to_s(:db),
                          end_date: tomorrow.to_s(:db)
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
end
