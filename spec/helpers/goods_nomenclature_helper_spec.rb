require 'spec_helper'

RSpec.describe GoodsNomenclatureHelper, type: :helper do
  before do
    session[:goods_nomenclature_code] = session_goods_nomenclature_code
    allow(helper).to receive(:url_options).and_return(url_options)
    allow(helper.request).to receive(:referer).and_return('http://example.com/commodities/2402201000?country=AE&day=25&month=12&year=2021#export')
  end

  let(:session_goods_nomenclature_code) { '1901200000' }
  let(:url_options) { { country: 'AR', year: '2021', month: '01', day: '01' } }

  describe '#goods_nomenclature_back_link' do
    let(:session_goods_nomenclature_code) { '1901200000' }

    it 'returns the correct link html' do
      expected_link = '<a class="govuk-back-link" href="/commodities/1901200000?country=AR&amp;day=01&amp;month=01&amp;year=2021#export">Back</a>'

      expect(helper.goods_nomenclature_back_link).to eq(expected_link)
    end
  end

  describe '#goods_nomenclature_link' do
    context 'when the session goods_nomenclature_code is a commodity code' do
      let(:session_goods_nomenclature_code) { '1901200000' }

      it 'returns a return link for the commodity' do
        expected_link = '<a class="govuk-link" href="/commodities/1901200000?country=AR&amp;day=01&amp;month=01&amp;year=2021#export">Return to 1901200000</a>'

        expect(helper.goods_nomenclature_link).to eq(expected_link)
      end
    end

    context 'when the session goods_nomenclature_code is a heading code' do
      let(:session_goods_nomenclature_code) { '1901' }

      it 'returns a return link for the heading' do
        expected_link = '<a class="govuk-link" href="/headings/1901?country=AR&amp;day=01&amp;month=01&amp;year=2021#export">Return to 1901</a>'

        expect(helper.goods_nomenclature_link).to eq(expected_link)
      end
    end
  end

  describe '#goods_nomenclature_path' do
    shared_examples_for 'a goods_nomenclature_path' do |goods_nomenclature_code, expected_path|
      let(:session_goods_nomenclature_code) { goods_nomenclature_code }

      it { expect(helper.goods_nomenclature_path).to eq(expected_path) }
    end

    it_behaves_like 'a goods_nomenclature_path', '1901200000', '/commodities/1901200000?country=AR&day=01&month=01&year=2021#export'
    it_behaves_like 'a goods_nomenclature_path', '1901', '/headings/1901?country=AR&day=01&month=01&year=2021#export'
    it_behaves_like 'a goods_nomenclature_path', '19', '/chapters/19?country=AR&day=01&month=01&year=2021#export'
    it_behaves_like 'a goods_nomenclature_path', nil, '/find_commodity?country=AR&day=01&month=01&year=2021'
  end

  describe '#current_goods_nomenclature_code' do
    before do
      session[:goods_nomenclature_code] = '1901200000'
    end

    it { expect(helper.current_goods_nomenclature_code).to eq('1901200000') }
  end
end
