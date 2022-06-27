require 'spec_helper'

RSpec.describe RulesOfOrigin::Article do
  it { is_expected.to respond_to :article }
  it { is_expected.to respond_to :content }
end
