require 'spec_helper'

RSpec.describe News::Year do
  it { is_expected.to respond_to :year }

  describe '.all' do
    subject { described_class.all }

    before do
      stub_api_request('/news/years', backend: 'uk')
          .to_return jsonapi_response :news_year, attributes_for_list(:news_year, 2)
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
