require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::NonAlterationRule do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped?' do
    subject { instance.skipped? }

    it { is_expected.to be true }
  end

  it_behaves_like 'an article accessor', :non_alteration_text, 'non-alteration'
end
