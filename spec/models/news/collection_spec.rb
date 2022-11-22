require 'spec_helper'

RSpec.describe News::Collection do
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :id }

  describe '#attributes' do
    subject { described_class.new resource_id: '1', name: 'test' }

    it { is_expected.to have_attributes resource_id: '1' }
    it { is_expected.to have_attributes id: 1 }
    it { is_expected.to have_attributes name: 'test' }
  end

  describe '.all' do
    subject { described_class.all }

    before do
      stub_api_request('/news/collections', backend: 'uk')
          .to_return jsonapi_response :news_collection, attributes_for_list(:news_collection, 2)
    end

    context 'with UK site' do
      include_context 'with UK service'

      it { is_expected.to have_attributes length: 2 }
    end

    context 'with XI site' do
      include_context 'with XI service'

      it { is_expected.to have_attributes length: 2 }
    end
  end
end
