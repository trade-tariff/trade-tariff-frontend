require 'spec_helper'

RSpec.describe ExchangeRatesController, type: :request, vcr: { cassette_name: 'exchange_rates', record: :new_episodes } do
  subject { response }

  describe 'GET #index' do
    context 'when exchange rate type is "monthly"' do
      before { get '/exchange_rates/monthly?year=2022' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/index' }
    end

    context 'when exchange rate type is "monthly" and the year has no data' do
      before { get '/exchange_rates/monthly?year=2000' }

      it { is_expected.to have_http_status :not_found }
      it { is_expected.to render_template 'exchange_rates/show_404' }
    end

    context 'when exchange rate type is "spot"' do
      before { get '/exchange_rates/spot' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/index' }
    end

    context 'when exchange rate type is "average"' do
      before { get '/exchange_rates/average' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/index' }
    end

    context 'when exchange rate type is NOT valid' do
      before { get '/exchange_rates/bad_type' }

      it { is_expected.to have_http_status :not_found }
      it { is_expected.to render_template 'exchange_rates/show_404' }
    end
  end

  describe 'GET #show' do
    context 'when exchange rate type is "monthly"' do
      before { get '/exchange_rates/view/2022-1?type=monthly' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/show' }
    end

    context 'when exchange rate type is "spot"' do
      before { get '/exchange_rates/view/2022-1-1?type=spot' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/show' }
    end

    context 'when exchange rate type is "average"' do
      before { get '/exchange_rates/view/2022-1-1?type=average' }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'exchange_rates/show' }
    end

    context 'when exchange rate type is NOT valid' do
      before { get '/exchange_rates/view/2022-1-1?type=bad_type' }

      it { is_expected.to have_http_status :not_found }
      it { is_expected.to render_template 'exchange_rates/show_404' }
    end
  end
end
