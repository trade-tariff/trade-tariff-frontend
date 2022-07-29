require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProofsOfOrigin do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be true }
  end
end
