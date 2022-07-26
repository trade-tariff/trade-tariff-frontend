require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::WhollyObtained do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :wholly_obtained }
  it { is_expected.to have_attributes options: %w[yes no] }

  describe '#validate' do
    it { is_expected.to allow_value('yes').for :wholly_obtained }
    it { is_expected.to allow_value('no').for :wholly_obtained }
    it { is_expected.not_to allow_value('random').for :wholly_obtained }
    it { is_expected.not_to allow_value('').for :wholly_obtained }
    it { is_expected.not_to allow_value(nil).for :wholly_obtained }
  end
end
