require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_direct_transport_rule', type: :view do
  include_context 'with rules of origin form step',
                  'direct_transport_rule',
                  :wholly_obtained

  let :articles do
    attributes_for_list :rules_of_origin_article, 1, article: 'direct-transport'
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Direct transport.*#{schemes.first.title}/ }
  it { is_expected.to have_css '#intro.tariff-markdown *' }
  it { is_expected.to have_css '#direct-transport-rule.tariff-markdown *' }
  it { is_expected.not_to have_css 'details', text: /Origin Reference Document/i }
  it { is_expected.not_to have_css '#unavailable' }

  context 'without direct transport article' do
    let(:articles) { [] }

    it { is_expected.not_to have_css '#direct-transport-rule' }
    it { is_expected.to have_css '#unavailable.tariff-markdown *' }
  end

  context 'with origin reference document reference' do
    let :articles do
      attributes_for_list :rules_of_origin_article, 1,
                          article: 'direct-transport',
                          content: "This includes a reference\n\n{{ article 12 }}"
    end

    it { is_expected.not_to have_css '#direct-transport-rule', text: /\{\{/ }
    it { is_expected.to have_css 'details', text: /Origin Reference Document/i }
  end
end
