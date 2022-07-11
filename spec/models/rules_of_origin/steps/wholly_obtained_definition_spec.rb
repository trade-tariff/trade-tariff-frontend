require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::WhollyObtainedDefinition do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor', :wholly_obtained_text, 'wholly-obtained'
  it_behaves_like 'an article accessor',
                  :wholly_obtained_vessels_text,
                  'wholly-obtained-vessels'
end
