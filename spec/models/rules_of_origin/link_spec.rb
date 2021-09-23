require 'spec_helper'

describe RulesOfOrigin::Link do
  it { is_expected.to respond_to :text }
  it { is_expected.to respond_to :url }
end
