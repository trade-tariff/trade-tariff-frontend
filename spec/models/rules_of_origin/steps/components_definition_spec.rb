require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ComponentsDefinition do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor', :neutral_elements_text, 'neutral-elements'
  it_behaves_like 'an article accessor', :packaging_text, 'packaging'
  it_behaves_like 'an article accessor', :packaging_retail_text, 'packaging_retail'
  it_behaves_like 'an article accessor', :accessories_text, 'accessories'
end
