require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_proof_verification', type: :view do
  include_context 'with rules of origin form step',
                  'tolerances',
                  :wholly_obtained

  let :articles do
    attributes_for_list :rules_of_origin_article, 1, article: 'tolerances'
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /originating/i }
  it { is_expected.to have_css 'h1', text: 'Tolerances' }
  it { is_expected.to have_css '#tolerances-examples.tariff-markdown details .govuk-details__text *' }
  it { is_expected.to have_css '#tolerances-article .tariff-markdown *' }
end
