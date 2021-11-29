RSpec.describe 'trading_partners/show.html.erb', type: :view, vcr: { cassette_name: 'geographical_areas#countries' } do
  subject { render }

  before { assign :trading_partner, trading_partner }

  let(:trading_partner) { TradingPartner.new(country: 'IT') }

  describe 'header' do
    it { is_expected.to have_css 'header span', text: /UK Integrated/ }
  end
end
