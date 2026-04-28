RSpec.describe DutyCalculator::Steps::BaseController, :user_session do
  controller do
    def index
      render plain: 'Hari Seldon'
    end

    def create
      render plain: 'Hari Seldon'

      raise ArgumentError, 'This is a test'
    end
  end

  let(:user_session) { build(:duty_calculator_user_session, :with_import_date, :with_commodity_information, session_id: 'foo') }
  let(:trade_tariff_host) { 'https://dev.trade-tariff.service.gov.uk' }

  let(:expected_tracked_attributes) do
    {
      session: user_session.session,
      commodity_code: '0702000007',
      commodity_source: 'uk',
      referred_service: 'uk',
    }
  end

  before do
    allow(Rails.configuration).to receive(:trade_tariff_frontend_url).and_return(trade_tariff_host)
  end

  describe 'Faraday::ResourceNotFound rescue_from registration' do
    it 'is registered as the rescue handler for Faraday::ResourceNotFound' do
      registered = described_class.rescue_handlers.detect { |klass, _| klass == 'Faraday::ResourceNotFound' }

      expect(registered).not_to be_nil
    end

    it 'delegates to handle_commodity_not_found' do
      registered = described_class.rescue_handlers.detect { |klass, _| klass == 'Faraday::ResourceNotFound' }

      expect(registered[1]).to eq(:handle_commodity_not_found)
    end

    it 'is positioned before the StandardError handler so it takes priority' do
      handlers = described_class.rescue_handlers
      not_found_index = handlers.index { |klass, _| klass == 'Faraday::ResourceNotFound' }
      standard_error_index = handlers.index { |klass, _| klass == 'StandardError' }

      expect(not_found_index).to be < standard_error_index
    end

    it 'does not notify NewRelic for a commodity not found error' do
      exception = Faraday::ResourceNotFound.new('commodity not found')
      allow(NewRelic::Agent).to receive(:notice_error)
      allow(controller).to receive(:sections_url).and_return('/sections')
      allow(controller).to receive(:redirect_to)

      controller.rescue_with_handler(exception)

      expect(NewRelic::Agent).not_to have_received(:notice_error)
    end
  end

  describe 'GET #index' do
    subject(:response) { get :index }

    it 'initializes the CommodityContextService' do
      response
      expect(Thread.current[:commodity_context_service]).to be_a(DutyCalculator::CommodityContextService)
    end

    context 'when commodity_code is not set' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it { expect(response).not_to redirect_to(trade_tariff_host) }
    end

    context 'when commodity_code is set' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

      it { expect(response).not_to redirect_to(trade_tariff_host) }
    end
  end
end
