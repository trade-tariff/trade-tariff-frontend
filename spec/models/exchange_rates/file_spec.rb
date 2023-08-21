require 'spec_helper'

RSpec.describe ExchangeRates::File do
  let(:file) { build(:exchange_rate_file) }

  it { is_expected.to respond_to :file_path }
  it { is_expected.to respond_to :file_size }
  it { is_expected.to respond_to :publication_date }
  it { is_expected.to respond_to :format }

  describe '#file_size_label' do
    it { expect(file.file_size_label).to eq 'CSV file (2.0 KB)' }
  end
end
