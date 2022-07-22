require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Subdivision do
  include_context 'with rules of origin store', :sufficient_processing
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :subdivision }

  describe 'validation' do
    let(:rule_set) { schemes.first.rule_sets.first }

    it { is_expected.to allow_value(rule_set.resource_id).for :subdivision }
    it { is_expected.not_to allow_value('random').for :subdivision }
    it { is_expected.not_to allow_value('').for :subdivision }
    it { is_expected.not_to allow_value(nil).for :subdivision }
  end

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

  describe '#options' do
    subject { instance.options.map(&:resource_id) }

    it { is_expected.to eql schemes.first.rule_sets.map(&:resource_id) }
  end
end
