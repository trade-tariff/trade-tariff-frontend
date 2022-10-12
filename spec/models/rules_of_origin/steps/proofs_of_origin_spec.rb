require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProofsOfOrigin do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be true }
  end

  describe 'duty_drawback_available?' do
    subject { instance.duty_drawback_available? }

    context 'with article' do
      let :articles do
        attributes_for_list :rules_of_origin_article, 1, article: 'duty-drawback'
      end

      it { is_expected.to be true }
    end

    context 'without article' do
      it { is_expected.to be false }
    end
  end
end
