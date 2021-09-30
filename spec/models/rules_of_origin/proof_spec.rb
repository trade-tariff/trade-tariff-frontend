require 'spec_helper'

describe RulesOfOrigin::Proof do
  it { is_expected.to respond_to :summary }
  it { is_expected.to respond_to :content }
end
