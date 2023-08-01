require 'spec_helper'

RSpec.describe ExchangeRates::PeriodList do
  let(:year) { 2023 }
  let(:api_host) { TradeTariffFrontend::ServiceChooser.api_host }
  let(:response_headers) { { content_type: 'application/json; charset=utf-8' } }
  let :response_data do
    {
      data: {
        id: '2023-exchange_rate_period_list',
        type: 'exchange_rate_period_list',
        attributes: {
          year:,
        },
        relationships: {
          exchange_rate_periods: {
            data: [
              {
                id: '2023-6-exchange_rate_period',
                type: 'exchange_rate_period',
                attributes: {
                  month: 6,
                  year:,
                },
              },
            ],
          },
          exchange_rate_years: {
            data: [
              {
                id: '2023-exchange_rate_year',
                type: 'exchange_rate_year',
                attributes: {
                  year: 2023,
                },
              },
            ],
          },
        },
      },
      included: [
        {
          id: '2023-6-exchange_rate_period',
          type: 'exchange_rate_period',
          attributes: {
            month: 6,
            year:,
          },
        },
        {
          id: '2023-exchange_rate_year',
          type: 'exchange_rate_year',
          attributes: {
            year:,
          },
        },
      ],
    }
  end

  it { is_expected.to respond_to :year }
  it { is_expected.to respond_to :exchange_rate_years }
  it { is_expected.to respond_to :exchange_rate_periods }

  describe '.find' do
    shared_context 'with mocked response' do
      subject(:period_list) { described_class.find(year) }

      before do
        stub_api_request("/exchange_rates/period_lists/?year=#{year}")
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
      end
    end

    include_context 'with mocked response'

    it { is_expected.to be_instance_of described_class }
    it { is_expected.to have_attributes year: }
    it { expect(period_list.exchange_rate_years).to have_attributes length: 1 }
    it { expect(period_list.exchange_rate_periods).to have_attributes length: 1 }

    context 'with first exchange rate period' do
      subject { period_list.exchange_rate_periods.first }

      it { is_expected.to have_attributes month: 6 }
      it { is_expected.to have_attributes year: }
    end

    context 'with first exchange rate year' do
      subject { period_list.exchange_rate_years.first }

      it { is_expected.to have_attributes year: }
    end
  end
end
