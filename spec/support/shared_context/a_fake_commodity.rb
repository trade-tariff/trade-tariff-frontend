RSpec.shared_context 'with a fake commodity' do
  let(:commodity_context_service) { instance_double(DutyCalculator::CommodityContextService) }

  let(:commodity) { build(:duty_calculator_commodity) }
  let(:uk_commodity) { nil }
  let(:xi_commodity) { nil }

  before do
    allow(commodity_context_service).to receive(:call).with('xi', anything, anything).and_return(xi_commodity.presence || commodity)
    allow(commodity_context_service).to receive(:call).with('uk', anything, anything).and_return(uk_commodity.presence || commodity)

    Thread.current[:commodity_context_service] = commodity_context_service
  end
end
