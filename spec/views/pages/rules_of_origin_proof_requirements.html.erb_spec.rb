require 'spec_helper'

RSpec.describe 'pages/rules_of_origin_proof_requirements', type: :view do
  subject { render && rendered }

  before do
    allow(view).to receive(:url_for).and_return 'stubbed'
    assign :country, country
    assign :chosen_scheme, scheme
    assign :article, article
  end

  let(:country) { build :geographical_area, description: 'Japan' }
  let(:scheme) { build :rules_of_origin_scheme }
  let(:article) { build :rules_of_origin_article, article: 'origin_processes', content: }
  let(:content) { "## First section\n\nfirst\n\n## Second section\n\nsecond\n" }

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Requirements.*Japan/ }
  it { is_expected.to have_css 'p', text: %r{processes.*#{scheme.title}} }
  it { is_expected.to have_css '.tariff-markdown *' }
  it { is_expected.to have_css '#article-section-list li a', count: 2 }
  it { is_expected.to have_link 'First section' }
  it { is_expected.to have_link 'Second section' }
  it { is_expected.to have_css '#article-section h2', count: 1, text: 'First section' }
  it { is_expected.to have_link 'Back to top' }
end
