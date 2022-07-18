require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProductSpecificRules do
  include_context 'with rules of origin store', :sufficient_processing
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context "when 'sufficient_processing' set to 'yes'" do
      include_context 'with rules of origin store', :sufficient_processing

      it { is_expected.to be false }
    end

    context "when 'sufficient_processing' set to 'no'" do
      include_context 'with rules of origin store', :insufficient_processing

      it { is_expected.to be true }
    end
  end

  describe '#commodity_description' do
    subject { instance.commodity_description }

    before do
      allow(Commodity).to receive(:find).with(wizardstore['commodity_code'])
                                        .and_return(commodity)
    end

    let :commodity do
      build :commodity, commodity_code: wizardstore['commodity_code']
    end

    it { is_expected.to eql commodity.description }
  end
end
