require 'spec_helper'

RSpec.describe 'myott/commodity_changes/ending.html.erb', type: :view do
  let(:tariff_change) do
    instance_double(TariffChanges::TariffChange,
                    goods_nomenclature_item_id: '1234567890',
                    classification_description: 'Test classification',
                    date_of_effect: '2025-12-31')
  end
  let(:change) { instance_double(TariffChanges::CommodityChange, count: 1, tariff_changes: [tariff_change]) }

  before do
    assign(:change, change)
    allow(view).to receive(:as_of).and_return(Date.new(2025, 11, 27))
    render
  end

  it 'renders the page title' do
    expect(rendered).to match(/Changes to end date/)
  end

  it 'shows the total commodities affected' do
    expect(rendered).to match(/Total commodities affected: 1/)
  end

  it 'renders the commodity code in the table' do
    expect(rendered).to match(/1234567890/)
  end

  it 'renders the classification description in the table' do
    expect(rendered).to match(/Test classification/)
  end

  it 'renders the date of effect in the table' do
    expect(rendered).to match(/2025-12-31/)
  end
end
