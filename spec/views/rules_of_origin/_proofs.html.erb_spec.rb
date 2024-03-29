require 'spec_helper'

RSpec.describe 'rules_of_origin/_proofs', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/proofs', schemes:,
                                     commodity_code: '2203000100',
                                     country_code: 'FR'
  end

  let(:schemes) { build_list :rules_of_origin_scheme, 1, :with_cds_proof_info, proof_count: 1 }

  it { is_expected.to have_css '#proofs-of-origin' }
  it { is_expected.to have_css '.govuk-list--bullet li a', count: 3 }

  it { is_expected.to have_css '.stacked-govuk-details', count: 1 }
  it { is_expected.to have_css 'p', text: /origin is valid/ }
  it { is_expected.to have_css 'details.govuk-details', count: 1 }
  it { is_expected.to have_css 'details .govuk-details__text *' }
  it { is_expected.to have_css '.cds-proof-info', count: 1 }

  context 'with multiple proofs' do
    let(:schemes) { build_list :rules_of_origin_scheme, 1, proof_count: 2 }

    it { is_expected.to have_css 'p', text: /are valid proofs/ }
    it { is_expected.to have_css 'details.govuk-details', count: 2 }
    it { is_expected.to have_css 'details .govuk-details__text *' }
  end

  context 'with multiple schemes' do
    let(:schemes) { build_list :rules_of_origin_scheme, 3, :with_cds_proof_info, proof_count: 2 }

    it { is_expected.not_to have_css '.govuk-list--bullet li a' }
    it { is_expected.to have_link 'See valid proofs of origin' }
    it { is_expected.to have_css '.stacked-govuk-details', count: 3 }
    it { is_expected.to have_css '.govuk-details', count: 6 }
    it { is_expected.to have_css '.cds-proof-info', count: 3 }
  end

  context 'without cds proof info' do
    let(:schemes) { build_list :rules_of_origin_scheme, 1 }

    it { is_expected.not_to have_css '.cds-proof-info' }
  end
end
