require 'spec_helper'

RSpec.describe 'subheadings/show', type: :view do
  subject(:rendered_page) { render }

  before do
    assign :subheading, subheading
    assign :commodities, HeadingCommodityPresenter.new(subheading.commodities)
    assign :search, Search.new
  end

  let(:subheading) { build :subheading, commodities_count: 3 }

  it { is_expected.to have_css 'h1', text: "Subheading #{subheading.code} - #{subheading.description}" }
  it { is_expected.to have_css 'dl.govuk-summary-list' }
  it { is_expected.to have_css 'strong', text: '3 commodities' }
  it { is_expected.to have_css 'nav.commodity-ancestors ol li', count: 4 }
  it { is_expected.to have_css '.commodity-tree ul li', count: 3 }
end
