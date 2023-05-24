require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper, vcr: { cassette_name: 'geographical_areas#it' } do
  describe '#declarable_stw_html' do
    subject(:declarable_stw_html) { helper.declarable_stw_html(declarable, search) }

    context 'when no country is selected' do
      let(:declarable) { build(:commodity, goods_nomenclature_item_id: '0101300020') }
      let(:search) { build(:search) }

      it { is_expected.to eq("<p>\n  To check how to import commodity 0101300020, select the country from which you are importing.\n</p>") }
    end

    context 'when the country is selected' do
      let(:declarable) { build(:commodity, goods_nomenclature_item_id: '0101300020') }
      let(:search) { build(:search, :with_country) }

      it { is_expected.to eq(helper.declarable_stw_link(declarable, search)) }
    end

    context 'when the declarable has conditionally prohibitive measures' do
      let(:declarable) { build(:commodity, :with_conditionally_prohibitive_measures, goods_nomenclature_item_id: '0101300020') }
      let(:search) { build(:search, :with_country) }

      it { is_expected.to eq("<p>\n  The import of commodity 0101300020 from Italy may be prohibited, depending on the additional code used.\n</p>") }
    end

    context 'when the declarable has prohibitive measures' do
      let(:declarable) { build(:commodity, :with_prohibitive_measures, goods_nomenclature_item_id: '0101300020') }
      let(:search) { build(:search, :with_country) }

      it { is_expected.to eq("<p>\n  The import of commodity 0101300020 from Italy is prohibited.\n</p>") }
    end

    context 'when the declarable has a mix of prohibitive and conditionally prohibitive measures' do
      let(:declarable) { build(:commodity, :with_conditionally_prohibitive_and_prohibitive_measures, goods_nomenclature_item_id: '0101300020') }
      let(:search) { build(:search, :with_country) }

      it { is_expected.to eq("<p>\n  The import of commodity 0101300020 from Italy is prohibited.\n</p>") }
    end
  end

  describe '#declarable_stw_link' do
    subject(:declarable_stw_link) { helper.declarable_stw_link(declarable, search) }

    let(:declarable) { build(:commodity) }

    let(:search) { build(:search, :with_search_date, :with_country, search_date:) }

    let(:search_date) { Date.parse('2021-01-01') }

    context 'when no date is passed' do
      let(:search) { build(:search, :with_country) }

      it { is_expected.to include("importDateDay=#{Time.zone.today.day}") }
      it { is_expected.to include("importDateMonth=#{Time.zone.today.month}") }
      it { is_expected.to include("importDateYear=#{Time.zone.today.year}") }
    end

    context 'when the declarable is a heading' do
      let(:declarable) { build(:heading) }

      it 'returns the expected text' do
        expected_text = "Check how to import heading #{declarable.code} from Italy (opens in a new tab)"

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=IT') }
      it { is_expected.to include('goodsIntent=bringGoodsToSell') }
      it { is_expected.to include('userTypeTrader=true') }
      it { is_expected.to include('tradeType=import') }
      it { is_expected.to include('destinationCountry=GB') }
      it { is_expected.to include('importDeclarations=yes') }
      it { is_expected.to include('importOrigin=&') }
      it { is_expected.to include('importDateDay=01') }
      it { is_expected.to include('importDateMonth=01') }
      it { is_expected.to include('importDateYear=2021') }
      it { is_expected.to include('target="_blank"') }
      it { is_expected.to include('rel="noopener"') }
      it { is_expected.to include('class="govuk-link"') }
    end

    context 'when the declarable is a commodity' do
      let(:declarable) { build(:commodity) }

      it 'returns the expected text' do
        expected_text = "Check how to import commodity #{declarable.code} from Italy (opens in a new tab)"

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=IT') }
      it { is_expected.to include('goodsIntent=bringGoodsToSell') }
      it { is_expected.to include('userTypeTrader=true') }
      it { is_expected.to include('tradeType=import') }
      it { is_expected.to include('destinationCountry=GB') }
      it { is_expected.to include('importDeclarations=yes') }
      it { is_expected.to include('importOrigin=&') }
      it { is_expected.to include('importDateDay=01') }
      it { is_expected.to include('importDateMonth=01') }
      it { is_expected.to include('importDateYear=2021') }
      it { is_expected.to include('target="_blank"') }
      it { is_expected.to include('rel="noopener"') }
      it { is_expected.to include('class="govuk-link"') }
    end
  end

  describe '#trading_partner_country_description' do
    context 'when the country is a valid country' do
      subject(:trading_partner_country_description) { helper.trading_partner_country_description('IT') }

      it { is_expected.to eq('Italy') }
    end

    context 'when the country is nil' do
      subject(:trading_partner_country_description) { helper.trading_partner_country_description(nil) }

      it { is_expected.to eq('All countries') }
    end
  end

  describe '#supplementary_unit_for' do
    subject(:supplementary_unit_for) { helper.supplementary_unit_for(uk_declarable, xi_declarable, country) }

    let(:uk_declarable) { instance_double('Commodity') }
    let(:xi_declarable) { instance_double('Commodity') }
    let(:country) { 'IT' }

    before do
      service_double = instance_double('DeclarableUnitService', call: '<p>supplementary unit</p>')

      allow(DeclarableUnitService).to receive(:new).with(uk_declarable, xi_declarable, country).and_return(service_double)
    end

    it { is_expected.to eq('<p>supplementary unit</p>') }
    it { is_expected.to be_html_safe }
  end
end
