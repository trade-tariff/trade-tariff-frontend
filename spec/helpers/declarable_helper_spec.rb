require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper do
  before do
    session[:declarable_code] = session_declarable_code
    allow(helper).to receive(:url_options).and_return(url_options)
  end

  let(:session_declarable_code) { '1901200000' }

  let(:url_options) { { country: 'AR', year: '2021', month: '01', day: '01' } }

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
