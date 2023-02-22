require 'spec_helper'

RSpec.describe AdditionalCodeSearchController, type: :request, vcr: { cassette_name: 'search#additional_code_search' } do
  describe 'GET #new' do
    before { get additional_code_search_path }

    it { expect(response).to have_http_status(:success) }

    it { expect(response).to render_template('search/additional_code_search') }
    it { expect(response).to render_template('search/additional_codes/_form') }
    it { expect(response).to render_template('search/additional_codes/_helper') }

    it { expect(assigns(:form)).to be_a(AdditionalCodeSearchForm) }
    it { expect(assigns(:query)).to eq({}) }
    it { expect(assigns(:additional_codes)).to eq([]) }

    it { expect(response.body).not_to include 'search-results' }
  end

  describe 'POST #create' do
    before do
      post additional_code_search_path, params:
    end

    context 'when searching by description' do
      let(:params) { { additional_code_search_form: { description: 'shanghai' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/additional_code_search') }
      it { expect(response).to render_template('search/additional_codes/_form') }
      it { expect(response).to render_template('search/additional_codes/_helper') }

      it { expect(assigns(:form)).to be_a(AdditionalCodeSearchForm) }
      it { expect(assigns(:query)).to eq({ code: nil, type: nil, description: 'shanghai' }) }
      it { expect(assigns(:additional_codes)).to all(be_a(AdditionalCode)) }

      it { expect(response.body).to include 'search-results' }
    end

    context 'when searching by code and type' do
      let(:params) { { additional_code_search_form: { code: '4119' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/additional_code_search') }
      it { expect(response).to render_template('search/additional_codes/_form') }
      it { expect(response).to render_template('search/additional_codes/_helper') }

      it { expect(assigns(:form)).to be_a(AdditionalCodeSearchForm) }
      it { expect(assigns(:query)).to eq({ code: '119', description: nil, type: '4' }) }
      it { expect(assigns(:additional_codes)).to all(be_a(AdditionalCode)) }

      it { expect(response.body).to include 'search-results' }
    end
  end
end
