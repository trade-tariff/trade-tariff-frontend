require 'spec_helper'

RSpec.describe RulesOfOrigin::V2Rule do
  it { is_expected.to respond_to :rule }
  it { is_expected.to respond_to :rule_class }
  it { is_expected.to respond_to :operator }
  it { is_expected.to respond_to :footnotes }

  describe '#only_wholly_obtained_class?' do
    subject { described_class.new(rule_class:).only_wholly_obtained_class? }

    context 'with no classes' do
      let(:rule_class) { nil }

      it { is_expected.to be false }
    end

    context 'with other classes' do
      let(:rule_class) { %w[A1 B2] }

      it { is_expected.to be false }
    end

    context 'with multiple classes including wholly obtained' do
      let(:rule_class) { %w[A1 WO B2] }

      it { is_expected.to be false }
    end

    context 'with only wholly obtained class' do
      let(:rule_class) { %w[WO] }

      it { is_expected.to be true }
    end
  end

  describe '#all_footnotes' do
    subject { rule.all_footnotes }

    context 'with no footnotes' do
      let(:rule) { build :rules_of_origin_v2_rule, footnotes: [] }

      it { is_expected.to be_nil }
    end

    context 'with footnotes' do
      let(:rule) { build :rules_of_origin_v2_rule, footnotes: %w[one two] }

      it { is_expected.to eq "one\n\ntwo" }
    end
  end
end
