require 'spec_helper'

RSpec.describe ExchangeRates::RatesList do
  let(:year) { 2023 }
  let(:month) { 6 }
  let(:api_host) { TradeTariffFrontend::ServiceChooser.api_host }
  let(:response_headers) { { content_type: 'application/json; charset=utf-8' } }
  let :response_data do
    {
      data: {
        id: '2023-6-exchange_rate_rate_list',
        type: 'exchange_rates_list',
        attributes: {
          year:,
          month:,
          publication_date:,
        },
        relationships: {
          exchange_rate_files: {
            data: [
              {
                id: '2023-6-exchange_rate_file',
                type: 'exchange_rate_file',
                attributes: {
                  month: 6,
                  year:,
                  file_path:,
                  file_size:,
                  format:,
                  publication_date:,
                },
              },
            ],
          },
          exchange_rates: {
            data: [
              {
                id: '2023-exchange_rate_year',
                type: 'exchange_rate_year',
                attributes: {
                  year: 2023,
                  month: 6,
                  country:,
                  country_code:,
                  currency_description:,
                  currency_code:,
                  rate:,
                  validity_start_date:,
                  validity_end_date:,
                },
              },
            ],
          },
        },
      },
      included: [
        {
          id: '2023-6-exchange_rate_file',
          type: 'exchange_rate_file',
          attributes: {
                  month: 6,
                  year:,
                  file_path:,
                  file_size:,
                  format:,
                  publication_date:,
                },
        },
        {
          id: '2023-06-AED',
          type: 'exchange_rate',
          attributes: {
                  year: 2023,
                  month: 6,
                  country:,
                  country_code:,
                  currency_description:,
                  currency_code:,
                  rate:,
                  validity_start_date:,
                  validity_end_date:,
                },
        },
      ],
    }
  end

  it { is_expected.to respond_to :month }
  it { is_expected.to respond_to :year }
  it { is_expected.to respond_to :exchange_rate_years }
  it { is_expected.to respond_to :exchange_rate_periods }

  describe '.all' do
    shared_context 'with mocked response' do
      subject(:rate_list) { described_class.all(month:, year:) }

      before do
        stub_api_request("/exchange_rates/period_lists/?month=#{month}&year=#{year}")
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
      end
    end

    include_context 'with mocked response'

    it { is_expected.to be_instance_of described_class }
    it { is_expected.to have_attributes month: }
    it { is_expected.to have_attributes year: }
    it { expect(rate_list.exchange_rate_files).to have_attributes length: 1 }
    it { expect(rate_list.exchange_rates).to have_attributes length: 1 }

    context 'with first exchange rate file' do
      subject { rate_list.exchange_rate_files.first }

      it { is_expected.to have_attributes month: 6 }
      it { is_expected.to have_attributes year: 2023 }
      it { is_expected.to have_attributes file_path: }
      it { is_expected.to have_attributes file_size: }
      it { is_expected.to have_attributes publication_date: }
      it { is_expected.to have_attributes format: }
    end

    context 'with first exchange rate' do
      subject { rate_list.exchange_rates.first }

      it { is_expected.to have_attributes year: }
      it { is_expected.to have_attributes month: }
      it { is_expected.to have_attributes country: }
      it { is_expected.to have_attributes country_code: }
      it { is_expected.to have_attributes currency_description: }
      it { is_expected.to have_attributes currency_code: }
      it { is_expected.to have_attributes rate: }
      it { is_expected.to have_attributes validity_start_date: }
      it { is_expected.to have_attributes validity_end_date: }
    end
  end
end
