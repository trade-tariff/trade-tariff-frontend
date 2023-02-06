require 'spec_helper'

RSpec.describe RulesOfOrigin::ProductSpecificRulesController, type: :request do
  subject { response }

  describe 'GET #index' do
    before do
      allow(RulesOfOrigin::Scheme).to receive(:with_rules_for_commodity).and_return(schemes)
      allow(Commodity).to receive(:find).with(commodity.to_param).and_return(commodity)
      allow(GeographicalArea).to receive(:all).and_return []

      get rules_of_origin_product_specific_rules_path(commodity)
    end

    let(:schemes) { build_list :rules_of_origin_scheme, 3, scheme_count: 3, rule_set_count: 2 }
    let(:commodity) { build :commodity }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
