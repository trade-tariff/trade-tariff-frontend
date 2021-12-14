require 'spec_helper'

RSpec.describe 'rules_of_origin/_ancestors.html.erb',
               type: :view,
               vcr: { cassette_name: 'commodities_2208909110' } do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) { render 'commodities/ancestors', commodity: commodity }
  let(:commodity) { CommodityPresenter.new Commodity.find('2208909110', as_of: '2018-11-15') }
  let(:row_count) { commodity.ancestors.length + 4 } # Section, Chapter, Heading, Commodity itself

  it { is_expected.to have_css 'nav.commodity-ancestors' }
  it { is_expected.to have_css %(nav[aria-label*="commodity code #{commodity.code}"]) }
  it { is_expected.to have_css 'nav a.govuk-skip-link', text: /commodity #{commodity.code}/ }
  it { is_expected.to have_css 'nav ol li', count: row_count }
  it { is_expected.to have_css 'li span.commodity-ancestors__identifier', count: row_count }
  it { is_expected.to have_css 'li span.commodity-ancestors__descriptor', count: row_count }
  it { is_expected.to have_css 'li#commodity-ancestors__section[aria-owns="commodity-ancestors__chapter"]' }
  it { is_expected.to have_css 'li#commodity-ancestors__chapter[aria-owns="commodity-ancestors__heading"]' }
  it { is_expected.to have_css 'li#commodity-ancestors__heading[aria-owns="commodity-ancestors__ancestor-1"]' }

  it 'checks the ancestors all chain ownership correctly' do
    commodity.ancestors.each_index do |index|
      expect(rendered_page).to have_css \
        %(li#commodity-ancestors__ancestor-#{index + 1}) +
          %([aria-owns="commodity-ancestors__ancestor-#{index + 2}"])
    end
  end
end
