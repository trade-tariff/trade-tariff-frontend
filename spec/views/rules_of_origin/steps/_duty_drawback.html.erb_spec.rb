require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_duty_drawback', type: :view do
  include_context 'with rules of origin form step',
                  'duty_drawback',
                  :wholly_obtained

  let :articles do
    attributes_for_list :rules_of_origin_article, 1, article: 'duty-drawback'
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Duty drawback.*Japan/ }
  it { is_expected.to have_css '#intro.tariff-markdown *' }
  it { is_expected.to have_css '#example .tariff-markdown *' }
  it { is_expected.to have_css '#example img' }
  it { is_expected.to have_css '#prohibition h2' }
  it { is_expected.to have_css '#prohibition .tariff-markdown *' }
  it { is_expected.not_to have_css '#unavailable' }

  context 'without duty drawback article' do
    let(:articles) { [] }

    it { is_expected.not_to have_css '#example' }
    it { is_expected.not_to have_css '#prohibition' }
    it { is_expected.to have_css '#unavailable.tariff-markdown *' }
  end
end
