require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_components_definition', type: :view do
  include_context 'with rules of origin form step',
                  'components_definition',
                  :originating

  let :articles do
    [
      attributes_for(:rules_of_origin_article, article: 'neutral-elements'),
      attributes_for(:rules_of_origin_article, article: 'packaging', content: 'packaging article'),
      attributes_for(:rules_of_origin_article, article: 'accessories', content: 'accessory article'),
    ]
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: /components/ }
  it { is_expected.to have_css 'p.govuk-body-l', text: /neutral elements/ }
  it { is_expected.to have_css '.govuk-inset-text *' }
  it { is_expected.to have_css 'h3', text: %r{elements.*#{schemes.first.title}} }
  it { is_expected.to have_css '.tariff-markdown details summary', text: /neutral/ }
  it { is_expected.to have_css '.tariff-markdown details .govuk-details__text ul' }
  it { is_expected.to have_css 'h3', text: %r{Packing materials.*#{schemes.first.title}} }
  it { is_expected.to have_css '.tariff-markdown > p', text: 'packaging article' }
  it { is_expected.to have_css 'h3', text: %r{Accessories} }
  it { is_expected.to have_css '.tariff-markdown > p', text: 'accessory article' }
  it { is_expected.to have_css 'h3', text: /Next step/ }
  it { is_expected.to have_css 'p', text: %r{Click on the 'Continue' button.*#{schemes.first.title}} }
  it { is_expected.to have_css 'form button[type=submit]' }
  it { is_expected.not_to have_css '.rules-of-origin-attachment-text' }

  context 'without accesories article' do
    let(:articles) { [] }

    it { is_expected.not_to have_css 'h3', text: %r{Accessories} }
  end

  context 'with article reference' do
    let(:article_reference) { 'article 123' }
    let(:article_reference_2) { 'article 2' }
    let(:article_reference_3) { 'article 3' }

    let :articles do
      [
        attributes_for(:rules_of_origin_article, article: 'neutral-elements', content: "neutral elements\n\n {{ #{article_reference} }}"),
        attributes_for(:rules_of_origin_article, article: 'packaging', content: "packaging article\n\n {{ #{article_reference_2} }}"),
        attributes_for(:rules_of_origin_article, article: 'accessories', content: "accessory article\n\n {{ #{article_reference_3} }}"),
      ]
    end

    it { is_expected.to have_css '.rules-of-origin-attachment-text', text: article_reference }
    it { is_expected.to have_css '.rules-of-origin-attachment-text', text: schemes.first.origin_reference_document.ord_title }
    it { is_expected.to have_css 'a[href]', text: /Download rules of origin reference document/ }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_version }
    it { is_expected.to have_css '.subtext', text: schemes.first.origin_reference_document.ord_date }

    it { is_expected.to have_css '.rules-of-origin-attachment-text', text: article_reference_2 }

    it { is_expected.to have_css '.rules-of-origin-attachment-text', text: article_reference_3 }
  end
end
