require 'spec_helper'

RSpec.describe RulesOfOrigin::V2Rule do
  it { is_expected.to respond_to :rule }
  it { is_expected.to respond_to :rule_class }
  it { is_expected.to respond_to :operator }
end
