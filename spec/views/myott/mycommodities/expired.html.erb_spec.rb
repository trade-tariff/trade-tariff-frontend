require 'spec_helper'

RSpec.describe 'myott/mycommodities/expired.html.erb', type: :view do
  subject(:rendered_page) do
    render
    rendered
  end

  let(:targets) do
    build(
      :kaminari,
      collection: [
        build(
          :subscription_target,
          target_object: build(:tariff_changes_commodity, validity_end_date: Date.new(2026, 4, 1)).attributes.symbolize_keys,
        ),
        build(
          :subscription_target,
          target_object: build(:tariff_changes_commodity, goods_nomenclature_item_id: '0987654321', validity_end_date: Date.new(2026, 4, 2)).attributes.symbolize_keys,
        ),
      ],
    )
  end

  before do
    assign(:targets, targets)
  end

  it 'renders the tablet and desktop table' do
    expect(rendered_page).to have_css('.myott-mycommodities__expired-table table.govuk-table')
    expect(rendered_page).to have_css('tbody.govuk-table__body tr.govuk-table__row', count: 2)
  end

  it 'renders the mobile summary cards' do
    expect(rendered_page).to have_css('.myott-mycommodities__expired-mobile-cards .govuk-summary-card', count: 2)
    expect(rendered_page).to have_text('Commodity: 0406902190')
    expect(rendered_page).to have_text('Commodity: 0987654321')
  end
end
