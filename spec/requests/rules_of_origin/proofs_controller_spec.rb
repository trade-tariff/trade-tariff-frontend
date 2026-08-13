require 'spec_helper'

RSpec.describe RulesOfOrigin::ProofsController, type: :request do
  subject { response }

  describe 'GET #index' do
    before do
      allow(RulesOfOrigin::Scheme).to receive(:all).with(include: 'proofs,origin_reference_document')
                                                   .and_return(schemes)

      get rules_of_origin_proofs_path
    end

    let(:schemes) { build_list :rules_of_origin_scheme, 3, scheme_count: 2 }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }

    it 'requests schemes with the origin reference document included so proof content can resolve {ord_url} links' do
      expect(RulesOfOrigin::Scheme).to have_received(:all).with(include: 'proofs,origin_reference_document')
    end
  end

  describe 'origin reference document links in proof content' do
    let(:scheme) do
      build(:rules_of_origin_scheme,
            proofs: [attributes_for(:rules_of_origin_proof,
                                    content: 'See the full text. <a href="{ord_url}">Origin Reference Document</a>')])
    end

    before do
      allow(RulesOfOrigin::Scheme).to receive(:all).and_return([scheme])

      get rules_of_origin_proofs_path
    end

    it 'renders a working link to the origin reference document, not a 404' do
      href = Capybara.string(response.body).find_link('Origin Reference Document')[:href]

      get href

      expect(response).to have_http_status :ok
    end
  end
end
