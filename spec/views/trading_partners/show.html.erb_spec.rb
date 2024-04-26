RSpec.describe 'trading_partners/show', type: :view, vcr: { cassette_name: 'geographical_areas#countries' } do
  subject { render }

  before { assign :trading_partner, trading_partner }

  let(:trading_partner) { TradingPartner.new(country: 'IT') }

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end

  context 'with XI service' do
    include_context 'with XI service'

    it { is_expected.to have_css '#trading-partner-country-hint', text: 'View EU' }
  end

  context 'with UK service' do
    include_context 'with UK service'

    it { is_expected.to have_css '#trading-partner-country-hint', text: 'View UK' }
  end
end
