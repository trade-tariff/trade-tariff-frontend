require 'spec_helper'

RSpec.describe RulesOfOrigin::Wizard do
  describe '.sections' do
    subject { described_class.sections }

    it { is_expected.to eql %w[details originating] }
  end

  describe '.grouped_steps' do
    subject { described_class.grouped_steps }

    let :grouped_steps do
      {
        'details' => [RulesOfOrigin::Steps::ImportExport],
        'originating' => [RulesOfOrigin::Steps::Originating],
      }
    end

    it { is_expected.to eql grouped_steps }
  end
end
