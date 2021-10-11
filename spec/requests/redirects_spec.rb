require 'spec_helper'

RSpec.describe 'URL redirects', type: :request do
  subject(:do_response) { get path }

  describe '/api/:version/commodities/:id' do
    let(:path) { "/api/v2/commodities/#{goods_nomenclature_item_id}?as_of=test&some=param" }

    context 'when the id is a chapter id' do
      let(:goods_nomenclature_item_id) { '9900000000' }

      it { is_expected.to redirect_to 'https://www.example.com/api/v2/chapters/99?as_of=test&some=param' }
    end

    context 'when the id is a heading id' do
      let(:goods_nomenclature_item_id) { '9999000000' }

      it { is_expected.to redirect_to 'https://www.example.com/api/v2/headings/9999?as_of=test&some=param' }
    end

    context 'when the id is a commodity id' do
      let(:goods_nomenclature_item_id) { '9999990000' }

      before do
        stub_request(:get, 'http://localhost:3018/commodities/9999990000?as_of=test&some=param')
      end

      it { is_expected.to eq(200) }
    end
  end

  describe '/api/v1/quotas/search' do
    context 'when a query is not supplied' do
      let(:path) { '/api/v1/quotas/search' }

      it { is_expected.to redirect_to 'https://www.example.com/api/v2/quotas/search' }
    end

    context 'when a query is supplied' do
      let(:path) { '/api/v1/quotas/search?as_of=test&some=param' }

      it { is_expected.to redirect_to 'https://www.example.com/api/v2/quotas/search?as_of=test&some=param' }
    end
  end
end
