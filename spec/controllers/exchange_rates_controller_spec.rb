require 'spec_helper'

RSpec.describe ExchangeRatesController, type: :controller do
  before { TradeTariffFrontend::ServiceChooser.service_choice = nil }

  context 'with xi as the service choice' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(true)
      TradeTariffFrontend::ServiceChooser.service_choice = 'xi'
    end

    context 'when accessing the index action' do
      it 'raises an exception' do
        expect { get :index }.to raise_exception(TradeTariffFrontend::FeatureUnavailable)
      end
    end

    context 'when accessing the show action' do
      it 'raises an exception' do
        expect { get :show, params: { id: 'some_id' } }.to raise_exception(TradeTariffFrontend::FeatureUnavailable)
      end
    end
  end
end
