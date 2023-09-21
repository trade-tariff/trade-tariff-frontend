require 'spec_helper'

RSpec.describe FootnoteSearchController, type: :request, vcr: { cassette_name: 'search#footnote_search', record: :new_episodes } do
  describe 'GET #new' do
    before { get footnote_search_path }

    it { expect(response).to have_http_status(:success) }

    it { expect(response).to render_template('search/footnote_search') }
    it { expect(response).to render_template('search/footnotes/_form') }

    it { expect(assigns(:form)).to be_a(FootnoteSearchForm) }
    it { expect(assigns(:query)).to eq({}) }
    it { expect(assigns(:footnotes)).to eq([]) }

    it { expect(response.body).not_to include 'search-results' }
  end

  describe 'POST #create' do
    before do
      post footnote_search_path, params:
    end

    context 'when searching by description' do
      let(:params) { { footnote_search_form: { description: 'alcohol' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/footnote_search') }
      it { expect(response).to render_template('search/footnotes/_form') }

      it { expect(assigns(:form)).to be_a(FootnoteSearchForm) }
      it { expect(assigns(:query)).to eq({ code: nil, type: '', description: 'alcohol' }) }
      it { expect(assigns(:footnotes)).to all(be_a(Footnote)) }

      it { expect(response.body).to include 'search-results' }
    end

    context 'when searching by code and type' do
      let(:params) { { footnote_search_form: { code: 'PI001' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/footnote_search') }
      it { expect(response).to render_template('search/footnotes/_form') }

      it { expect(assigns(:form)).to be_a(FootnoteSearchForm) }
      it { expect(assigns(:query)).to eq({ code: '001', description: nil, type: 'PI' }) }
      it { expect(assigns(:footnotes)).to all(be_a(Footnote)) }

      it { expect(response.body).to include 'search-results' }
    end
  end
end
