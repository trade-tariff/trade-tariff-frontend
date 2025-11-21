require 'spec_helper'

RSpec.describe 'myott/grouped_measure_commodity_changes/show.html.erb', type: :view do
  let(:impacted_measures) do
    {
      'Preferential tariff quota' => [
        { 'date_of_effect' => '2025-12-01', 'change_type' => 'Measure will begin' },
      ],
    }
  end

  let(:grouped_measure_commodity_change) do
    OpenStruct.new(
      goods_nomenclature_item_id: '1234567890',
      classification_description: 'Test Classification',
      trade_direction: 'import',
      geographical_area_description: 'United Kingdom',
      chapter: '01',
      heading: '0101',
      impacted_measures: impacted_measures,
    )
  end

  before do
    assign(:grouped_measure_commodity_changes, grouped_measure_commodity_change)
    allow(view).to receive_messages(as_of: Date.new(2025, 11, 21), commodity_path: '/commodities/1234567890?day=1&month=12&year=2025')
    render
  end

  it 'renders the commodity code' do
    expect(rendered).to match(/Commodity 1234567890/)
  end

  it 'renders the classification description' do
    expect(rendered).to match(/Test Classification/)
  end

  it 'renders the trade direction' do
    expect(rendered).to match(/Import/)
  end

  it 'renders the geographical area' do
    expect(rendered).to match(/United Kingdom/)
  end

  it 'renders the chapter' do
    expect(rendered).to match(/01/)
  end

  it 'renders the heading' do
    expect(rendered).to match(/0101/)
  end

  it 'renders the impacted measure type' do
    expect(rendered).to match(/Preferential tariff quota/)
  end

  it 'renders the change type' do
    expect(rendered).to match(/Measure will begin/)
  end

  it 'renders the date of effect' do
    expect(rendered).to match(/01\/12\/2025/)
  end

  it 'renders the link to the commodity' do
    expect(rendered).to have_link('View commodity on 01/12/2025', href: '/commodities/1234567890?day=1&month=12&year=2025')
  end
end
