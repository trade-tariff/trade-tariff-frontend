require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Subdivisions do
  include_context 'with rules of origin store',
                  :sufficient_processing,
                  scheme_traits: %i[subdivided]
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :subdivision_id }

  describe 'validation' do
    let(:rule_set) { schemes.first.rule_sets.first }

    it { is_expected.to allow_value(rule_set.resource_id).for :subdivision_id }
    it { is_expected.not_to allow_value('random').for :subdivision_id }
    it { is_expected.not_to allow_value('').for :subdivision_id }
    it { is_expected.not_to allow_value(nil).for :subdivision_id }
  end

  describe '#skipped' do
    subject { instance.skipped? }

    context 'with subdivided rulesets' do
      context "when 'sufficient_processing' set to 'yes'" do
        it { is_expected.to be false }
      end

      context "when 'sufficient_processing' set to 'no'" do
        include_context 'with rules of origin store',
                        :insufficient_processing,
                        scheme_traits: :subdivided

        it { is_expected.to be true }
      end
    end

    context 'when no subdivided rule_sets' do
      include_context 'with rules of origin store', :sufficient_processing

      it { is_expected.to be true }
    end

    context 'when wholly obtained' do
      include_context 'with rules of origin store',
                      :wholly_obtained,
                      scheme_traits: :subdivided

      it { is_expected.to be true }
    end

    context 'when only single wholly obtained rule but not wholly obtained' do
      include_context 'with rules of origin store',
                      :not_wholly_obtained,
                      scheme_traits: :single_wholly_obtained_rule

      it { is_expected.to be true }
    end
  end

  describe '#declareable_description' do
    subject { instance.declareable_description }

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
        wizardstore['commodity_code'] = "9302000000"
        allow(Heading).to receive(:find).with("9302")
                                          .and_return(heading)
      end

      let :heading do
        build :heading, commodity_code: wizardstore['commodity_code']
      end

      it { is_expected.to eql heading.description }
    end
  end

  describe '#options' do
    subject { instance.options }

    let :schemes do
      build_list :rules_of_origin_scheme, 1, countries: [country.id], rule_sets:
    end

    let :rule_sets do
      attributes_for_pair(:rules_of_origin_rule_set, :subdivided) +
        attributes_for_list(:rules_of_origin_rule_set, 1)
    end

    it { is_expected.to include schemes.first.rule_sets.first }
    it { is_expected.to include schemes.first.rule_sets.second }
    it { is_expected.not_to include schemes.first.rule_sets.third }
  end
end
