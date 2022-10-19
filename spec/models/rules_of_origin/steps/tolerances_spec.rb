require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Tolerances do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped?' do
    subject { instance.skipped? }

    it { is_expected.to be true }
  end

  it_behaves_like 'an article accessor', :tolerances_text, 'tolerances'
end
