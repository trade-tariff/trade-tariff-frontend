require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Originating do
  include_context 'with rules of origin store', :importing
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#originating_country' do
    subject { instance.originating_country }

    context 'when importing' do
      it { is_expected.to eql 'Japan' }
    end

    context 'when exporting' do
      include_context 'with rules of origin store', :exporting

      it { is_expected.to eql 'United Kingdom' }
    end
  end
end
