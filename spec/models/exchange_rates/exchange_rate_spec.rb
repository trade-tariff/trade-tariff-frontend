require 'spec_helper'

RSpec.describe ExchangeRates::ExchangeRate do
  it { is_expected.to respond_to :year }
  it { is_expected.to respond_to :month }
  it { is_expected.to respond_to :country }
  it { is_expected.to respond_to :country_code }
  it { is_expected.to respond_to :currency_description }
  it { is_expected.to respond_to :currency_code }
  it { is_expected.to respond_to :rate }
  it { is_expected.to respond_to :validity_start_date }
  it { is_expected.to respond_to :validity_end_date }
end
