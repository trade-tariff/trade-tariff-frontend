require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_import_only', type: :view do
  include_context 'with rules of origin form step', 'import_only'

  it { is_expected.to have_css 'h1', text: /importing .* the United Kingdom .* GSP scheme/im }
  it { is_expected.to have_css '.govuk-caption-xl', text: /trading .* \d{10} with Japan/i }
  it { is_expected.to have_css 'p', text: /Japan .* unilateral/m }
  it { is_expected.to have_link 'Generalised System of Preferences (GSP)' }

  it { is_expected.to have_css 'p', text: /export goods to Japan/ }
  it { is_expected.to have_css 'p a[href]', text: /Find out about the product-specific rules/ }
end
