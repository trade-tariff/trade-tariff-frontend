RSpec.describe 'trading_partners/show', type: :view, vcr: { cassette_name: 'geographical_areas#countries' } do
  subject { render }

  before { assign :trading_partner, trading_partner }

  let(:trading_partner) { TradingPartner.new(country: 'IT') }

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end

  describe 'Tariff specific change' do
    include_context 'with XI service'
    it { is_expected.to have_css 'form', text: / View EU / }
  end

  describe 'Tariff specific change' do
    include_context 'with UK service'
    it { is_expected.not_to have_css 'form', text: / View EU / }
  end
end
