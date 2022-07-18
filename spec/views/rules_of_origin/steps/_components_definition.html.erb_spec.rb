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

  context 'without accesories article' do
    let(:articles) { [] }

    it { is_expected.not_to have_css 'h3', text: %r{Accessories} }
  end
end
