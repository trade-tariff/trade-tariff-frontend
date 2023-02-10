require 'spec_helper'

RSpec.describe RulesOfOrigin::ProofsController, type: :request do
  subject { response }

  describe 'GET #index' do
    before do
      allow(RulesOfOrigin::Scheme).to receive(:all).with(include: 'proofs')
                                                   .and_return(schemes)

      get rules_of_origin_proofs_path
    end

    let(:schemes) { build_list :rules_of_origin_scheme, 3, scheme_count: 2 }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
