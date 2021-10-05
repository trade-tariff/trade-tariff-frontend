require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper do
  before do
    session[:declarable_code] = session_declarable_code
  end

  let(:session_declarable_code) { '1901200000' }

  describe '#return_to_declarable_link' do
    context 'when the session declarable_code is a commodity code' do
      let(:session_declarable_code) { '1901200000' }

      it 'returns a return link for the commodity' do
        expected_link = '<a class="govuk-link" anchor="import" href="/commodities/1901200000#import">Return to 1901200000</a>'

        expect(helper.return_to_declarable_link).to eq(expected_link)
      end
    end

    context 'when the session declarable_code is a heading code' do
      let(:session_declarable_code) { '1901' }

      it 'returns a return link for the heading' do
        expected_link = '<a class="govuk-link" anchor="import" href="/headings/1901#import">Return to 1901</a>'

        expect(helper.return_to_declarable_link).to eq(expected_link)
      end
    end
  end

  describe '#declarable_path' do
    context 'when the session declarable_code is a commodity code' do
      let(:session_declarable_code) { '1901200000' }

      it 'returns a valid url path' do
        expected_path = '/commodities/1901200000#import'

        expect(helper.declarable_path).to eq(expected_path)
      end
    end

    context 'when the session declarable_code is a heading code' do
      let(:session_declarable_code) { '1901' }

      it 'returns a valid url path' do
        expected_path = '/headings/1901#import'

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
