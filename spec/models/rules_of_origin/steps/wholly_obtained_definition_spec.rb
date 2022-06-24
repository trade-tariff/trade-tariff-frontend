require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::WhollyObtainedDefinition do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#scheme_title' do
    subject { instance.scheme_title }

    it { is_expected.to eql schemes.first.title }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2,
                                                                chosen_scheme: 2

      it { is_expected.to eql schemes.second.title }
    end
  end
end
