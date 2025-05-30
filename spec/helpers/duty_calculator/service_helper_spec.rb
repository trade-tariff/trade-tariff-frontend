RSpec.describe ServiceHelper, :user_session do
  before do
    allow(Rails.configuration).to receive(:trade_tariff_frontend_url).and_return(frontend_url)

    allow(controller).to receive(:params).and_return(params)
  end

  let(:params) do
    ActionController::Parameters.new(
      referred_service: service,
    ).permit(:referred_service)
  end

  let(:service) { 'uk' }

  let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

  let(:user_session) { build(:user_session) }

  describe '#title' do
    context 'when referred_service is xi' do
      let(:service) { 'xi' }

      it { expect(helper.title).to eq('Northern Ireland Online Tariff') }
    end

    context 'when referred_service is uk' do
      let(:service) { 'uk' }

      it { expect(helper.title).to eq('UK Integrated Online Tariff') }
    end
  end

  describe '#header' do
    context 'when referred_service is xi' do
      let(:service) { 'xi' }

      it { expect(helper.header).to eq('Northern Ireland Online Tariff') }
    end

    context 'when referred_service is uk' do
      let(:service) { 'uk' }

      it { expect(helper.header).to eq('UK Integrated Online Tariff') }
    end

    context 'when referred_service is not set at all' do
      let(:service) { nil }

      it { expect(helper.header).to eq('UK Integrated Online Tariff') }
    end
  end

  shared_examples_for 'a service url' do |helper_method, path|
    context 'when frontend url is set and service is not set' do
      let(:service) { nil }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.public_send(helper_method)).to eq("https://dev.trade-tariff.service.gov.uk#{path}") }
    end

    context 'when frontend url is set and service is `uk`' do
      let(:service) { 'uk' }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.public_send(helper_method)).to eq("https://dev.trade-tariff.service.gov.uk#{path}") }
    end

    context 'when frontend url is set and service is `xi`' do
      let(:service) { 'xi' }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.public_send(helper_method)).to eq("https://dev.trade-tariff.service.gov.uk/xi#{path}") }
    end

    context 'when frontend url is not set' do
      let(:frontend_url) { nil }

      it { expect(helper.public_send(helper_method)).to eq('#') }
    end
  end

  it_behaves_like 'a service url', :sections_url, '/sections'
  it_behaves_like 'a service url', :search_url, '/find_commodity'
  it_behaves_like 'a service url', :browse_url, '/browse'
  it_behaves_like 'a service url', :a_to_z_url, '/a-z-index/a'
  it_behaves_like 'a service url', :tools_url, '/tools'
  it_behaves_like 'a service url', :news_url, '/news'
  it_behaves_like 'a service url', :feedback_url, '/feedback'
  it_behaves_like 'a service url', :help_url, '/help'

  describe '#previous_service_url' do
    let(:commodity_code) { '0702000007' }
    let(:user_session) { build(:user_session) }

    context 'when redirect_to is set' do
      let(:user_session) { build(:user_session, redirect_to: 'https://example.com/chieg') }

      it { expect(helper.previous_service_url(commodity_code)).to eq('https://example.com/chieg') }
    end

    context 'when TRADE_TARIFF_FRONTEND_URL is set' do
      it 'returns the dev trade tariff tools url' do
        expect(helper.previous_service_url(commodity_code)).to eq(
          "https://dev.trade-tariff.service.gov.uk/commodities/#{commodity_code}",
        )
      end
    end

    context 'when TRADE_TARIFF_FRONTEND_URL is not set' do
      let(:frontend_url) { nil }

      it 'returns the dev trade tariff tools url' do
        expect(helper.previous_service_url(commodity_code)).to eq('#')
      end
    end
  end

  describe '#commodity_url' do
    let(:commodity_code) { '0702000007' }

    context 'when frontend url is set' do
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.commodity_url(commodity_code)).to eq("https://dev.trade-tariff.service.gov.uk/commodities/#{commodity_code}") }
    end

    context 'when frontend url is not set' do
      let(:frontend_url) { nil }

      it 'returns the correct url' do
        expect(helper.commodity_url(commodity_code)).to eq('#')
      end
    end
  end

  describe '#feedback_url' do
    context 'when choice is nil' do
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.feedback_url).to eq('https://dev.trade-tariff.service.gov.uk/feedback') }
    end

    context 'when choice is no' do
      let(:choice) { 'no' }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.feedback_url(choice)).to eq("https://dev.trade-tariff.service.gov.uk/feedback?page_useful=#{choice}") }
    end

    context 'when choice is yes' do
      let(:choice) { 'yes' }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.feedback_url(choice)).to eq("https://dev.trade-tariff.service.gov.uk/feedback?page_useful=#{choice}") }
    end

    context 'when choice is invalid' do
      let(:choice) { 'invalid' }
      let(:frontend_url) { 'https://dev.trade-tariff.service.gov.uk' }

      it { expect(helper.feedback_url(choice)).to eq('https://dev.trade-tariff.service.gov.uk/feedback') }
    end
  end

  describe '#referred_service' do
    subject(:result) { helper.referred_service }

    context 'when the service comes from the url params' do
      let(:params) { ActionController::Parameters.new(referred_service:).permit(:referred_service) }

      context 'when the url params value is the exact uk service' do
        let(:referred_service) { 'uk' }

        it { is_expected.to eq('uk') }
      end

      context 'when the url params value is the exact xi service' do
        let(:referred_service) { 'xi' }

        it { is_expected.to eq('xi') }
      end

      context 'when the url params value is anything but the xi or uk service' do
        let(:referred_service) { 'https://redirect.here/phishing' }

        it { is_expected.to eq('uk') }
      end
    end

    context 'when the service comes from the session' do
      let(:params) { ActionController::Parameters.new(referred_service: nil).permit(:referred_service) }
      let(:user_session) { build(:user_session, referred_service:) }

      context 'when the session value is the exact uk service' do
        let(:referred_service) { 'uk' }

        it { is_expected.to eq('uk') }
      end

      context 'when the session value is the exact xi service' do
        let(:referred_service) { 'xi' }

        it { is_expected.to eq('xi') }
      end

      context 'when the session value is anything but the xi or uk service' do
        let(:referred_service) { 'https://redirect.here/phishing' }

        it { is_expected.to eq('uk') }
      end
    end

    context 'when the service is not present on the url params or the session' do
      let(:params) { ActionController::Parameters.new(referred_service: nil).permit(:referred_service) }
      let(:user_session) { build(:user_session, referred_service: nil) }

      it { is_expected.to eq('uk') }
    end
  end
end
