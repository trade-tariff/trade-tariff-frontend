require 'spec_helper'

RSpec.describe 'pages/rules_of_origin_proof_verification', type: :view do
  subject { render && rendered }

  before do
    assign :country, country
    assign :chosen_scheme, scheme
    assign :article, article
  end

  let(:country) { build :geographical_area, description: 'Japan' }
  let(:scheme) { build :rules_of_origin_scheme }
  let(:article) { build :rules_of_origin_article, article: 'verification' }

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Verification.*Japan/ }
  it { is_expected.to have_css '.tariff-markdown *' }

  context 'with article reference' do
    let :article do
      build :rules_of_origin_article,
            article: 'verification',
            content: "Some content\n\n{{ article 123 }}"
    end

    it { is_expected.to have_link 'Download rules of origin reference document' }
  end
end
