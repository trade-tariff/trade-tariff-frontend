RSpec.describe CertificateSearchController, type: :request, vcr: { cassette_name: 'search#certificate_search', record: :new_episodes } do
  describe 'GET #new' do
    before { get certificate_search_path }

    it { expect(response).to have_http_status(:success) }

    it { expect(response).to render_template('search/certificate_search') }
    it { expect(response).to render_template('search/certificate/_form') }

    it { expect(assigns(:form)).to be_a(CertificateSearchForm) }
    it { expect(assigns(:query)).to eq({}) }
    it { expect(assigns(:certificates)).to eq([]) }

    it { expect(response.body).not_to include 'search-results' }
  end

  describe 'POST #create' do
    before do
      post certificate_search_path, params:
    end

    context 'when searching by description' do
      let(:params) { { certificate_search_form: { description: 'veterinary' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/certificate_search') }
      it { expect(response).to render_template('search/certificate/_form') }

      it { expect(assigns(:form)).to be_a(CertificateSearchForm) }
      it { expect(assigns(:query)).to eq({ code: nil, type: nil, description: 'veterinary' }) }
      it { expect(assigns(:certificates)).to all(be_a(Certificate)) }

      it { expect(response.body).to include 'search-results' }
    end

    context 'when searching by code and type' do
      let(:params) { { certificate_search_form: { code: 'C640' } } }

      it { expect(response).to have_http_status(:success) }

      it { expect(response).to render_template('search/certificate_search') }
      it { expect(response).to render_template('search/certificate/_form') }

      it { expect(assigns(:form)).to be_a(CertificateSearchForm) }
      it { expect(assigns(:query)).to eq({ code: '640', description: nil, type: 'C' }) }
      it { expect(assigns(:certificates)).to all(be_a(Certificate)) }

      it { expect(response.body).to include 'search-results' }
    end
  end
end
