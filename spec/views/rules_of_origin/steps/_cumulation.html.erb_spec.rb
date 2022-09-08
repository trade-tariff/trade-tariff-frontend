require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_cumulation', type: :view, vcr: { cassette_name: 'geographical_areas#countries', allow_playback_repeats: true } do
  include_context 'with rules of origin form step',
                  'cumulation',
                  :originating

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: /parts or components/ }
  it { is_expected.to have_css 'p strong', text: 'cumulation rules' }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: %r{Cumulation.*#{schemes.first.title}} }
  it { is_expected.to have_css 'p', text: %r{Map showing countries.*#{schemes.first.title}} }
  it { is_expected.to have_css '.govuk-inset-text', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css 'details.govuk-details summary', text: %r{cumulation.*#{schemes.first.title}} }
  it { is_expected.to have_css 'details.govuk-details div.govuk-details__text' }
  it { is_expected.to have_css 'h3.govuk-heading-s', text: /Next step/ }
  it { is_expected.to have_css '#next-step p', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css 'h2', text: %r{Methods of cumulation .*#{schemes.first.title}} }
  it { is_expected.to have_css 'p', text: %r{The #{schemes.first.title} .* 2 methods of cumulation} }
  it { is_expected.to have_css 'span', text: 'Bilateral cumulation - an example' }
  it { is_expected.to have_css 'span', text: 'Extended cumulation - an example' }
  it { is_expected.to have_css 'p img[src*="cumulation/bilateral"]' }
  it { is_expected.to have_css 'p img[src*="cumulation/extended"]' }
  it { is_expected.not_to have_css '.downloadable-document__text' }

  context 'with article reference' do
    let(:article_reference) { 'article 123' }

    let :articles do
      [
        attributes_for(:rules_of_origin_article,
                       article: 'cumulation-import',
                       content: "## Title\n\n1. Numbered list\n\n {{ #{article_reference} }}"),
      ]
    end

    it { is_expected.to have_css '.downloadable-document__text', text: article_reference }
    it { is_expected.to have_css '.downloadable-document__text', text: schemes.first.origin_reference_document.ord_title }
    it { is_expected.to have_css 'a[href]', text: /Download rules of origin reference document/ }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_version }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_date }

    context 'when exporting' do
      include_context 'with rules of origin store', :not_wholly_obtained, :exporting

      let(:article_reference) { 'article 123' }

      let :articles do
        [
          attributes_for(:rules_of_origin_article,
                         article: 'cumulation-export',
                         content: "## Title\n\n1. Numbered list\n\n {{ #{article_reference} }}"),
        ]
      end

      it { is_expected.to have_css '.downloadable-document__text', text: article_reference }
      it { is_expected.to have_css '.downloadable-document__text', text: schemes.first.origin_reference_document.ord_title }
      it { is_expected.to have_css 'a[href]', text: /Download rules of origin reference document/ }
      it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_version }
      it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_date }
    end
  end
end
