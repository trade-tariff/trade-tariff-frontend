require 'spec_helper'

RSpec.describe RulesOfOrigin::Proof do
  it { is_expected.to respond_to :summary }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :subtext }
end
