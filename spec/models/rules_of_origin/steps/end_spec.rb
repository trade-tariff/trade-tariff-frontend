require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::End do
  include_context 'with rules of origin store'
  include_context 'with wizard step', RulesOfOrigin::Wizard
end
