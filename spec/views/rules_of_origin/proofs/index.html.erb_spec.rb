require 'spec_helper'

RSpec.describe 'rules_of_origin/proofs/index', type: :view do
  subject { render }

  before { assign :schemes, schemes }

  let(:schemes) { build_list :rules_of_origin_scheme, 3, proof_count: 2 }

  it { is_expected.to have_link 'Back' }

  it { is_expected.to have_css 'h1', text: 'Proofs of origin for all trade agreements' }
  it { is_expected.to have_css '.govuk-caption-xl', text: 'Rules of origin' }

  describe 'Contents section' do
    let(:link_id) { "#proofs-for-#{schemes.first.scheme_code}" }

    it { is_expected.to have_css 'h2', text: 'Contents' }
    it { is_expected.to have_css '.gem-c-contents-list__list li', count: 3 }
    it { is_expected.to have_link schemes.first.title, href: link_id }
    it { is_expected.to have_css link_id }
  end

  describe 'Proofs' do
    it { is_expected.to have_css 'h2.govuk-heading-m', count: 3 }
    it { is_expected.to have_css 'h2.govuk-heading-m', text: schemes.first.title }

    it { is_expected.to have_css '.stacked-govuk-details details.govuk-details', count: 6 }
    it { is_expected.to have_css 'details summary', text: schemes.first.proofs.first.summary }
    it { is_expected.to have_css 'details .govuk-details__text *' }
  end
end
