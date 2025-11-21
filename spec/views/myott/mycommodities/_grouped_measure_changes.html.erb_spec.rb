require 'spec_helper'

RSpec.describe 'myott/mycommodities/_grouped_measure_changes.html.erb', type: :view do
  let(:change) do
    build(
      :grouped_measure_change,
      trade_direction: 'import',
      geographical_area: { 'long_description' => 'United Kingdom' },
      count: 3,
      resource_id: 42,
    )
  end

  before do
    allow(change).to receive(:geographical_area_description).and_return('United Kingdom')
    assign(:grouped_measure_changes, [change])
    allow(view).to receive(:params).and_return(as_of: '2025-11-21')
    render partial: 'myott/mycommodities/grouped_measure_changes', locals: { grouped_measure_changes: [change] }
  end

  it 'renders the trade direction' do
    expect(rendered).to match(/Import/)
  end

  it 'renders the geographical area' do
    expect(rendered).to match(/United Kingdom/)
  end

  it 'renders the commodities affected as a link' do
    expect(rendered).to have_link('3 commodities', href: '/subscriptions/grouped_measure_changes/42?as_of=2025-11-21')
  end
end
