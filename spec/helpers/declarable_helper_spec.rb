require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper do
  before do
    session[:declarable_code] = session_declarable_code
    allow(helper).to receive(:url_options).and_return(url_options)
  end

  let(:session_declarable_code) { '1901200000' }

  let(:url_options) { { country: 'AR', year: '2021', month: '01', day: '01' } }

  describe '#declarable_stw_link' do
    subject(:declarable_stw_link) { helper.declarable_stw_link(declarable, search) }

    let(:declarable) { build(:commodity) }
    let(:geographical_area) { build(:geographical_area, id: 'FR', description: 'France') }
    let(:search) { Search.new(country: 'FR', day: '01', month: '01', year: '2021') }

    before do
      allow(GeographicalArea).to receive(:find).and_return(geographical_area)
    end

    context 'when no date is passed' do
      let(:search) { Search.new(country: 'FR') }

      it { is_expected.to include("importDateDay=#{Time.zone.today.day}") }
      it { is_expected.to include("importDateMonth=#{Time.zone.today.month}") }
      it { is_expected.to include("importDateYear=#{Time.zone.today.year}") }
    end

    context 'when the declarable is a heading' do
      let(:declarable) { build(:heading) }

      it 'returns the correct expected text' do
        expected_text = "Check how to import heading #{declarable.code} from France."

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=FR') }
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

      it 'returns the correct expected text' do
        expected_text = "Check how to import commodity #{declarable.code} from France."

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=FR') }
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

  describe '#declarable_back_link' do
    context 'when the session declarable_code is a commodity code' do
      let(:session_declarable_code) { '1901200000' }

      it 'returns a return link for the commodity' do
        expected_link = '<a class="govuk-back-link" href="/commodities/1901200000?country=AR&amp;day=01&amp;month=01&amp;year=2021#import">Back</a>'

        expect(helper.declarable_back_link).to eq(expected_link)
      end
    end

    context 'when the session declarable_code is a heading code' do
      let(:session_declarable_code) { '1901' }

      it 'returns a return link for the commodity' do
        expected_link = '<a class="govuk-back-link" href="/headings/1901?country=AR&amp;day=01&amp;month=01&amp;year=2021#import">Back</a>'

        expect(helper.declarable_back_link).to eq(expected_link)
      end
    end
  end

  describe '#declarable_link' do
    context 'when the session declarable_code is a commodity code' do
      let(:session_declarable_code) { '1901200000' }

      it 'returns a return link for the commodity' do
        expected_link = '<a class="govuk-link" href="/commodities/1901200000?country=AR&amp;day=01&amp;month=01&amp;year=2021#import">Return to 1901200000</a>'

        expect(helper.declarable_link).to eq(expected_link)
      end
    end

    context 'when the session declarable_code is a heading code' do
      let(:session_declarable_code) { '1901' }

      it 'returns a return link for the heading' do
        expected_link = '<a class="govuk-link" href="/headings/1901?country=AR&amp;day=01&amp;month=01&amp;year=2021#import">Return to 1901</a>'

        expect(helper.declarable_link).to eq(expected_link)
      end
    end
  end

  describe '#declarable_path' do
    context 'when the session declarable_code is a commodity code' do
      let(:session_declarable_code) { '1901200000' }

      it 'returns a valid url path' do
        expected_path = '/commodities/1901200000?country=AR&day=01&month=01&year=2021#import'

        expect(helper.declarable_path).to eq(expected_path)
      end
    end

    context 'when the session declarable_code is a heading code' do
      let(:session_declarable_code) { '1901' }

      it 'returns a valid url path' do
        expected_path = '/headings/1901?country=AR&day=01&month=01&year=2021#import'

        expect(helper.declarable_path).to eq(expected_path)
      end
    end
  end

  describe '#current_declarable_code' do
    before do
      session[:declarable_code] = '1901200000'
    end

    it { expect(helper.current_declarable_code).to eq('1901200000') }
  end
end
