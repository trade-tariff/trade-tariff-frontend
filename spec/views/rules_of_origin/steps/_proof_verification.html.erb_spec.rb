require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_proof_verification', type: :view do
  include_context 'with rules of origin form step',
                  'proof_verification',
                  :wholly_obtained

  let :articles do
    attributes_for_list :rules_of_origin_article, 1, article: 'verification'
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Verification.*Japan/ }
  it { is_expected.to have_css '.tariff-markdown *' }

  context 'with article reference' do
    let(:article_reference) { 'article 123' }

    let :articles do
      attributes_for_list :rules_of_origin_article, 1,
                          article: 'verification',
                          content: "Some content\n\n{{ #{article_reference} }}"
    end

    it { is_expected.to have_link 'Download rules of origin reference document' }
  end
end
