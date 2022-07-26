require 'spec_helper'

RSpec.describe RulesOfOrigin::RuleSet do
  it { is_expected.to respond_to :heading }
  it { is_expected.to respond_to :subdivision }
  it { is_expected.to respond_to :rules }
end
