require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_wholly_obtained_definition', type: :view do
  include_context 'with rules of origin form step',
                  'wholly_obtained_definition',
                  :originating

  let :articles do
    [
      attributes_for(:rules_of_origin_article,
                     article: 'wholly-obtained',
                     content: "## Title\n\n1. Numbered list\n"),
      attributes_for(:rules_of_origin_article, article: 'wholly-obtained-vessels'),
    ]
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: %r{wholly obtained.+#{schemes.first.title}} }
  it { is_expected.to have_css 'p.govuk-body-l', text: /wholly obtained/ }
  it { is_expected.to have_css '.tariff-markdown ol li' }
  it { is_expected.to have_css 'details.govuk-details summary' }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text' }
  it { is_expected.to have_css '.tariff-markdown p', text: %r{#{schemes.first.title}} }
  it { is_expected.not_to have_css '.downloadable-document__text' }

  context 'with article reference' do
    let(:article_reference) { 'article 123' }
    let(:article_reference_2) { 'article 2' }

    let :articles do
      [
        attributes_for(:rules_of_origin_article,
                       article: 'wholly-obtained',
                       content: "## Title\n\n1. Numbered list\n\n {{ #{article_reference} }}"),
        attributes_for(:rules_of_origin_article,
                       article: 'wholly-obtained-vessels',
                       content: "## Title\n\n1. Numbered list\n\n {{ #{article_reference_2} }}"),
      ]
    end

    it { is_expected.to have_css '.downloadable-document__text', text: article_reference }
    it { is_expected.to have_css '.downloadable-document__text', text: schemes.first.origin_reference_document.ord_title }
    it { is_expected.to have_css 'a[href]', text: /Download rules of origin reference document/ }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_version }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_date }

    it { is_expected.to have_css '.downloadable-document__text', text: article_reference_2 }
  end

  context 'when wholly obtained vessels article does not exist' do
    let(:articles) { [] }

    it { is_expected.not_to have_css 'details.govuk-details summary' }
  end
end
