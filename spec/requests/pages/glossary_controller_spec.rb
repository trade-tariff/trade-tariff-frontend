require 'spec_helper'

RSpec.describe Pages::GlossaryController, type: :request do
  subject { response }

  describe 'GET #index' do
    before { get glossary_terms_path }

    it { is_expected.to have_http_status :ok }
  end

  describe 'GET #show' do
    context 'with known page' do
      before { get glossary_term_path('vnm') }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to render_template 'pages/glossary/_vnm' }
    end

    context 'with unknown page' do
      before do
        get glossary_term_path('unknown_page')
      end

      it { expect(response).to have_http_status(:internal_server_error) }
    end
  end
end
