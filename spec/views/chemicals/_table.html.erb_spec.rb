require 'spec_helper'

RSpec.describe 'chemicals/_table', type: :view do
  subject(:rendered_page) do
    render 'chemicals/table', chemicals: chemicals
    rendered
  end

  let(:chemicals) { build_list :chemical_substance, 2 }

  it { is_expected.to have_css 'table' }
  it { is_expected.to have_css 'th abbr[title="Chemical Abstracts Service Registry Number"]', text: 'CAS RN' }
  it { is_expected.to have_css 'th abbr[title="European Union unique chemical identifier"]', text: 'CUS number' }
  it { is_expected.to have_css 'th', text: 'Name' }

  it 'renders a row for each chemical' do
    expect(rendered_page).to have_css('td', text: chemicals.first.cas_rn)
      .and have_css('td', text: chemicals.first.cus)
      .and have_css('td', text: chemicals.first.name)
      .and have_css('td', text: chemicals.last.cas_rn)
  end

  it 'renders the correct number of rows' do
    expect(rendered_page).to have_css('tbody tr', count: 2)
  end

  context 'when there are no chemicals' do
    let(:chemicals) { [] }

    it { is_expected.to have_css 'table' }
    it { is_expected.not_to have_css 'tbody tr' }
  end
end
