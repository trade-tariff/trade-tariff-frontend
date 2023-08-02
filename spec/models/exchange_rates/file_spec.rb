require 'spec_helper'

RSpec.describe ExchangeRates::File do
  it { is_expected.to respond_to :file_path }
  it { is_expected.to respond_to :file_size }
  it { is_expected.to respond_to :publication_date }
  it { is_expected.to respond_to :format }
end
