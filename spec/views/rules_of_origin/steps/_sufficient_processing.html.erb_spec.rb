require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_sufficient_processing', type: :view do
  include_context 'with rules of origin form step', 'sufficient_processing'

  let :articles do
    attributes_for_list :rules_of_origin_article, 1,
                        article: 'insufficient-processing'
  end

  it { is_expected.to have_css 'form > h1', text: /Have non-originating parts/ }
  it { is_expected.to have_css 'fieldset legend.govuk-fieldset__legend--m', text: /Have non-originating parts/ }
  it { is_expected.to have_css 'input[type="radio"]', count: 2 }
  it { is_expected.to have_css '.tariff-markdown p' }
  it { is_expected.to have_css 'details.govuk-details summary' }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text *' }
  it { is_expected.to have_css '#insufficient-processing-article h3' }
  it { is_expected.to have_css '#insufficient-processing-article .tariff-markdown *' }
  it { is_expected.not_to have_css '.downloadable-document__text' }

  context 'with invalid submission' do
    before { current_step.validate }

    it { is_expected.to have_css '.govuk-error-message', text: /Select whether/i }
  end

  context 'with article reference' do
    let(:article_reference) { 'article 123' }
    let :articles do
      [
        attributes_for(:rules_of_origin_article,
                       article: 'insufficient-processing',
                       content: "## Title\n\n1. Numbered list\n\n {{ #{article_reference} }}"),
      ]
    end

    it { is_expected.to have_css '.downloadable-document__text', text: article_reference }
    it { is_expected.to have_css '.downloadable-document__text', text: schemes.first.origin_reference_document.ord_title }
    it { is_expected.to have_link 'Download rules of origin reference document' }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_version }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_date }
  end
end
