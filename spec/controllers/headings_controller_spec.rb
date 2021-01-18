require 'spec_helper'

describe HeadingsController, 'GET to #show', type: :controller do
  context 'with existing heading id provided', vcr: { cassette_name: 'headings#show' } do
    let!(:heading) { Heading.new(attributes_for(:heading).stringify_keys) }

    before do
      get :show, params: { id: heading.to_param }
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:heading)).to be_a(HeadingPresenter) }
    it { expect(assigns(:commodities)).to be_a(HeadingCommodityPresenter) }
  end

  context 'with non existing chapter id provided', vcr: { cassette_name: 'headings#show_0110' } do
    let(:heading_id) { '0110' } # heading 0110 does not exist

    before do
      get :show, params: { id: heading_id }
    end

    it 'redirects to sections index page as fallback' do
      expect(response.status).to eq 302
      expect(response.location).to eq sections_url
    end
  end
end
