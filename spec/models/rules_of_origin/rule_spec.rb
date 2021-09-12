require 'spec_helper'

describe RulesOfOrigin::Rule do
  it { is_expected.to respond_to :id_rule }
  it { is_expected.to respond_to :heading }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :rule }
end
