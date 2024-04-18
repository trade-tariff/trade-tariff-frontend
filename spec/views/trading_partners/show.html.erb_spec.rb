RSpec.describe 'trading_partners/show', type: :view, vcr: { cassette_name: 'geographical_areas#countries' } do
  subject { render }

  before { assign :trading_partner, trading_partner }

  let(:trading_partner) { TradingPartner.new(country: 'IT') }

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end

  describe 'Tariff specific change xi' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to \
        receive(:service_choice).and_return 'xi'
    end

    it { is_expected.to have_css 'form', text: / View EU / }
  end

  describe 'Tariff specific change uk' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to \
        receive(:service_choice).and_return 'uk'
    end

    it { is_expected.not_to have_css 'form', text: / View EU / }
  end
end
