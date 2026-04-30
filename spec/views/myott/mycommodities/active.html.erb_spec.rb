require 'spec_helper'

RSpec.describe 'myott/mycommodities/active.html.erb', type: :view do
  subject(:rendered_page) do
    render
    rendered
  end

  let(:targets) do
    build(
      :kaminari,
      collection: [
        build(:subscription_target),
        build(
          :subscription_target,
          target_object: build(:tariff_changes_commodity, goods_nomenclature_item_id: '0987654321').attributes.symbolize_keys,
        ),
      ],
    )
  end

  before do
    assign(:targets, targets)
  end

  it { is_expected.to have_css('.myott-mycommodities__responsive-table table.govuk-table') }

  it { is_expected.to have_css('tbody.govuk-table__body tr.govuk-table__row', count: 2) }

  it { is_expected.to have_css('.myott-mycommodities__responsive-mobile-cards .govuk-summary-card', count: 2) }

  it { is_expected.to have_text('Commodity: 0406902190') }

  it { is_expected.to have_text('Commodity: 0987654321') }
end
