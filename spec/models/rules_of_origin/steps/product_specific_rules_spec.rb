require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProductSpecificRules do
  include_context 'with rules of origin store', :sufficient_processing
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :rule }

  describe 'validation' do
    let(:rule) { schemes.first.v2_rules.first }

    it { is_expected.to allow_value(rule.resource_id).for :rule }
    it { is_expected.to allow_value('none').for :rule }
    it { is_expected.not_to allow_value('random').for :rule }
    it { is_expected.not_to allow_value('').for :rule }
    it { is_expected.not_to allow_value(nil).for :rule }
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

    context 'when wholly obtained' do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be true }
    end

    context 'when only single wholly obtained rule but not wholly obtained' do
      include_context 'with rules of origin store',
                      :not_wholly_obtained,
                      scheme_traits: :single_wholly_obtained_rule

      it { is_expected.to be true }
    end
  end

  describe '#declarable_description' do
    subject { instance.declarable_description }

    before do
      allow(Commodity).to receive(:find).with(wizardstore['commodity_code'])
                                        .and_return(commodity)
    end

    let :commodity do
      build :commodity, commodity_code: wizardstore['commodity_code']
    end

    it { is_expected.to eql commodity.description }

    context 'when heading code' do
      before do
        wizardstore['commodity_code'] = '9302000000'
        allow(Heading).to receive(:find).with('9302')
                                          .and_return(heading)
      end

      let :heading do
        build :heading, commodity_code: wizardstore['commodity_code']
      end

      it { is_expected.to eql heading.description }
    end
  end

  describe '#options' do
    subject { instance.options.map(&:resource_id) }

    it { is_expected.to eql schemes.first.v2_rules.map(&:resource_id) + %w[none] }
  end

  describe '#rules' do
    subject { instance.rules }

    context 'with no subdivision chosen' do
      it { is_expected.to eql schemes.first.v2_rules }
    end

    context 'with subdivision' do
      include_context 'with rules of origin store', :subdivided

      it { is_expected.to eql schemes.first.rule_sets.second.rules }
    end
  end
end
