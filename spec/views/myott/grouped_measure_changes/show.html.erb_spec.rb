require 'spec_helper'

RSpec.describe 'myott/grouped_measure_changes/show.html.erb', type: :view do
  let(:measure_change_attrs) { attributes_for(:grouped_measure_commodity_change, count: 2, resource_id: 'import_IL__0807190050') }
  let(:grouped_measure_changes) do
    build(
      :grouped_measure_change,
      trade_direction: 'import',
      geographical_area: { 'long_description' => 'United Kingdom' },
      grouped_measure_commodity_changes: [measure_change_attrs],
      count: 2,
      resource_id: 99,
    )
  end

  before do
    allow(grouped_measure_changes).to receive_messages(trade_direction_description: 'Imports', geographical_area_description: 'United Kingdom')
    assign(:grouped_measure_changes, grouped_measure_changes)
    allow(view).to receive(:params).and_return(as_of: '2025-11-21')
    render
  end

  it 'renders the trade direction and area' do
    expect(rendered).to match(/Imports from United Kingdom/)
  end

  it 'renders the commodity code' do
    expect(rendered).to match(/1234567890/)
  end

  it 'renders the classification description' do
    expect(rendered).to match(/Test Classification/)
  end

  it 'renders the number of changes' do
    expect(rendered).to match(/2/)
  end

  it 'renders the commodities affected as a link' do
    expect(rendered).to have_link('2 changes', href: '/subscriptions/grouped_measure_commodity_changes/import_IL__0807190050?as_of=2025-11-21')
  end
end
