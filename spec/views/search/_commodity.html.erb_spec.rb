RSpec.describe 'search/_commodity', type: :view do
  subject { render }

  before do
    assign(:search, build(:search, q: 'test'))
    allow(view).to receive(:commodity).and_return(commodity)
  end

  context 'when there are ancestor descriptions' do
    let(:commodity) { build(:commodity, :with_other_ancestor_descriptions) }

    it { is_expected.to have_css('td.govuk-table__cell > a > strong', text: 'Other') }
  end

  context 'when there are no ancestor descriptions' do
    let(:commodity) { build(:commodity, description: 'Horses') }

    it { is_expected.to have_css('td.govuk-table__cell > a', text: 'Horses') }
  end
end
