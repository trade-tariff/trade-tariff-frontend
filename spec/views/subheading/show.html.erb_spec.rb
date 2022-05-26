require 'spec_helper'

RSpec.describe 'subheadings/show', type: :view do
  subject(:rendered_page) { render }

  before do
    assign :subheading, subheading
    assign :commodities, HeadingCommodityPresenter.new(subheading.commodities)
    assign :subheading_commodities, [subheading.find_self_in_commodities_list]
    assign :search, Search.new
  end

  let :subheading do
    build :subheading, goods_nomenclature_sid: commodities[3][:goods_nomenclature_sid],
                       ancestors: commodities.first(3),
                       commodities:
  end

  let :commodities do
    attributes_for_list :commodity, 7 do |commodity, index|
      next if index.zero?

      commodity[:parent_sid] = commodity[:goods_nomenclature_sid] - 1
    end
  end

  it { is_expected.to have_css 'h1', text: "Subheading #{subheading.code} - #{subheading.description}" }
  it { is_expected.to have_css 'dl.govuk-summary-list' }
  it { is_expected.to have_css 'strong', text: '1 commodity' }
  it { is_expected.to have_css 'nav.commodity-ancestors ol li', count: 7 }
  it { is_expected.to have_css '.commodity-tree ul li', count: 4 }
end
