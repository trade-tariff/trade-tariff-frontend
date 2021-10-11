RSpec.shared_context 'with UK service' do
  before do
    allow(TradeTariffFrontend::ServiceChooser).to \
      receive(:service_choice).and_return 'uk'
  end
end

RSpec.shared_context 'with XI service' do
  before do
    allow(TradeTariffFrontend::ServiceChooser).to \
      receive(:service_choice).and_return 'xi'
  end
end

RSpec.shared_context 'with default service' do
  before do
    allow(TradeTariffFrontend::ServiceChooser).to \
      receive(:service_choice).and_return nil
  end
end
