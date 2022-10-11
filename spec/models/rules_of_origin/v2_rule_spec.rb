require 'spec_helper'

RSpec.describe RulesOfOrigin::V2Rule do
  it { is_expected.to respond_to :rule }
  it { is_expected.to respond_to :rule_class }
  it { is_expected.to respond_to :operator }

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
end
