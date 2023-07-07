require 'spec_helper'

RSpec.describe ExchangeRates::Period do
  it { is_expected.to respond_to :year }
  it { is_expected.to respond_to :month }
end
