RSpec.describe 'search/_commodity', type: :view do
  subject(:rendered) { render }

  let(:request_id) { 'search-request-123' }

  before do
    assign(:search, build(:search, q: 'test', request_id:))
    allow(view).to receive(:commodity).and_return(commodity)
  end

  context 'when there are ancestor descriptions' do
    let(:commodity) { build(:commodity, :with_other_ancestor_descriptions) }

    it { is_expected.to have_css('td.govuk-table__cell > a > strong', text: 'Other') }
  end

  context 'when there are no ancestor descriptions' do
    let(:commodity) { build(:commodity, description: 'Horses') }

    it { is_expected.to have_css('td.govuk-table__cell > a', text: 'Horses') }

    it 'renders a commodity link with the expected href' do
      link = Capybara.string(rendered).find('td.commodity-result a', text: 'Horses')

      expect(link[:href]).to eq(commodity_path(commodity, request_id:))
    end
  end
end
