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

  describe '#adjusted_file_path' do
    before do
      allow(TradeTariffFrontend).to receive(:backend_base_domain).and_return(backend_base_domain)
    end

    context 'when application load balancer origin is blank' do
      let(:backend_base_domain) { nil }

      it 'returns the file path' do
        expect(file.adjusted_file_path).to eq '/exchange_rates/csv/exrates-monthly-0623.csv'
      end
    end

    context 'when application load balancer origin is present' do
      let(:backend_base_domain) { 'http://example.com/' }

      it 'returns the adjusted file path' do
        expect(file.adjusted_file_path).to eq 'http://example.com/exchange_rates/csv/exrates-monthly-0623.csv'
      end
    end
  end
end
