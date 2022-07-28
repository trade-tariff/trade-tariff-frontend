require 'spec_helper'

RSpec.feature 'Rules of Origin wizard', type: :feature do
  before do
    allow(Commodity).to receive(:find).and_return commodity

    allow(GeographicalArea).to receive(:all).and_return [japan]
    allow(GeographicalArea).to receive(:find).with('JP').and_return japan
    allow(RulesOfOrigin::Scheme).to receive(:all).with(commodity.code, 'JP')
                                                 .and_return schemes
  end

  let(:commodity) { build :commodity }
  let(:japan) { build :geographical_area, :japan }
  let(:schemes) { build_list :rules_of_origin_scheme, 1 }

  scenario 'Single trade agreement - Importing - Wholly obtained' do
    visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

    expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
    click_on 'Check rules of origin'

    expect(page).to have_css 'h1', text: /importing goods/
    choose 'I am importing goods'
    click_on 'Continue'

    expect(page).to have_css 'h1', text: /are classed as 'originating'/
    click_on 'Continue'

    expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
    click_on 'Continue'

    expect(page).to have_css 'h1', text: /What components/
    click_on 'Continue'

    expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
    choose 'Yes, my goods are wholly obtained'
    click_on 'Continue'

    expect(page).to have_css 'h1', text: /Origin requirements met/
    click_on 'See valid proofs of origin'

    expect(page).to have_css 'h1', text: 'Valid proofs of origin'
  end
end
