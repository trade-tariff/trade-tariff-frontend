require 'spec_helper'

RSpec.describe Pages::GlossaryController, type: :request do
  subject { response }

  describe 'GET #show' do
    context 'with known page' do
      before { get glossary_term_path('vnm') }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to render_template 'pages/glossary/_vnm' }
    end

    context 'with unknown page' do
      let(:fetch_page) { get glossary_term_path('unknown_page') }

      it { expect { fetch_page }.to raise_exception Pages::Glossary::UnknownPage }
    end
  end
end
