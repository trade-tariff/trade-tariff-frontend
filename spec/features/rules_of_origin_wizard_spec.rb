require 'spec_helper'

RSpec.feature 'Rules of Origin wizard', type: :feature do
  before do
    allow(Commodity).to receive(:find).and_return commodity

    allow(GeographicalArea).to receive(:all).and_return [japan]
    allow(GeographicalArea).to receive(:find).with('JP').and_return japan
    allow(RulesOfOrigin::Scheme).to receive(:all).with(commodity.code, 'JP')
                                                 .and_return schemes
  end

  let(:commodity) { build(:commodity, :with_import_trade_summary) }
  let(:japan) { build :geographical_area, :japan }

  context 'with single trade agreement' do
    let(:schemes) { build_list :rules_of_origin_scheme, 1 }

    scenario 'Importing - Wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
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

    scenario 'Importing - Not wholly obtained - Insufficient processing' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
      choose 'I am importing goods'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /are classed as 'originating'/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /What components/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
      choose 'No, my goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Your goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Including parts or components'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /non-originating parts been sufficiently processed/
      choose 'No'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Rules of Origin not met'
    end

    scenario 'Importing - Not wholly obtained - Sufficient Processing - Rules met' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
      choose 'I am importing goods'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /are classed as 'originating'/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /What components/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
      choose 'No, my goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Your goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Including parts or components'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /non-originating parts been sufficiently processed/
      choose 'Yes'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Do your goods meet the product-specific rules?'
      choose schemes.first.rule_sets.first.rules.first.rule
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Origin requirements met/
      click_on 'See valid proofs of origin'

      expect(page).to have_css 'h1', text: 'Valid proofs of origin'
    end

    scenario 'Importing - Not wholly obtained - Sufficient Processing - Rules not met' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
      choose 'I am importing goods'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /are classed as 'originating'/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /What components/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
      choose 'No, my goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Your goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Including parts or components'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /non-originating parts been sufficiently processed/
      choose 'Yes'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Do your goods meet the product-specific rules?'
      choose 'goods do not meet any'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Rules of Origin not met'
    end
  end

  context 'with single GSP trade agreement' do
    let(:schemes) { build_list :rules_of_origin_scheme, 1, unilateral: true }

    scenario 'Wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Importing goods.*from countries which belong to the GSP scheme/
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

  context 'with multiple trade agreements' do
    let(:schemes) { build_list :rules_of_origin_scheme, 2 }

    scenario 'Choosing second agreement then wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Select agreement for trading with/
      choose schemes.second.title
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
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

  context 'with multilateral and GSP trade agreements' do
    let(:multilateral) { build :rules_of_origin_scheme }
    let(:unilateral) { build :rules_of_origin_scheme, unilateral: true }
    let(:schemes) { [multilateral, unilateral] }

    scenario 'Choosing GSP then Wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Select agreement for trading with/
      choose unilateral.title
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Importing goods.*from countries which belong to the GSP scheme/
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

  context 'with subdivided rules' do
    let(:schemes) { build_list :rules_of_origin_scheme, 1, :subdivided }

    scenario 'Importing - Not wholly obtained - Sufficient Processing - Subdivided - Rules met' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
      choose 'I am importing goods'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /are classed as 'originating'/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /What components/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
      choose 'No, my goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Your goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Including parts or components'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /non-originating parts been sufficiently processed/
      choose 'Yes'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Provide more information about your product'
      choose schemes.first.rule_sets.first.subdivision
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Do your goods meet the product-specific rules?'
      choose schemes.first.rule_sets.first.rules.first.rule
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Origin requirements met/
      click_on 'See valid proofs of origin'

      expect(page).to have_css 'h1', text: 'Valid proofs of origin'
    end
  end

  context 'with single wholly obtained rule' do
    let :schemes do
      build_list :rules_of_origin_scheme, 1, :single_wholly_obtained_rule
    end

    scenario 'Importing - Wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
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

    scenario 'Importing - Not wholly obtained' do
      visit commodity_path(commodity, country: 'JP', anchor: 'rules-of-origin')

      expect(page).to have_css 'h2', text: 'Preferential rules of origin for trading with Japan'
      click_on 'Check rules of origin'

      expect(page).to have_css 'h1', text: /Are you importing goods.*UK.*Japan\?/
      choose 'I am importing goods'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /are classed as 'originating'/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /How 'wholly obtained' is defined/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /What components/
      click_on 'Continue'

      expect(page).to have_css 'h1', text: /Are your goods wholly obtained/
      choose 'No, my goods are not wholly obtained'
      click_on 'Continue'

      expect(page).to have_css 'h1', text: 'Rules of Origin not met'
    end
  end
end
