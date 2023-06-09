require 'spec_helper'

RSpec.describe 'rules_of_origin/_cds_proof_info', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/cds_proof_info', scheme:
  end

  let(:scheme) { build :rules_of_origin_scheme, :with_cds_proof_info }

  it { is_expected.to have_css '.scheme-proof-intro.tariff-markdown > *' }
  it { is_expected.to have_css '.govuk-table thead th', count: 2 }
  it { is_expected.to have_css '.govuk-table tbody td', count: 4 }
  it { is_expected.to have_css '.govuk-table tbody td.tariff-markdown > *', count: 2 }

  context 'without cds proof info' do
    let(:scheme) { build :rules_of_origin_scheme }

    it { is_expected.not_to have_css '.scheme-proof-intro *' }
    it { is_expected.not_to have_css '.govuk-table' }
  end
end
