require 'spec_helper'

RSpec.describe MyottHelper, type: :helper do
  describe '#myott_page_title' do
    let(:default_title) { 'UK Online Trade Tariff' }

    before do
      helper.instance_variable_set(:@content_for, {})
    end

    context 'when no title is provided' do
      it 'returns the default title' do
        expect(helper.myott_page_title).to eq(default_title)
      end

      it 'returns existing content_for title if set' do
        helper.content_for :title, 'Existing Title'
        expect(helper.myott_page_title).to eq('Existing Title')
      end
    end

    context 'when title is provided without error boolean' do
      it 'sets content_for to formatted title' do
        helper.myott_page_title('Login')
        expect(helper.content_for(:title)).to eq("Login | #{default_title}")
      end
    end

    context 'when title is provided with error boolean' do
      it 'sets content_for without error prefix when form has no errors' do
        helper.myott_page_title('Login', error: false)
        expect(helper.content_for(:title)).to eq("Login | #{default_title}")
      end

      it 'sets content_for with error prefix when form has errors' do
        helper.myott_page_title('Login', error: true)
        expect(helper.content_for(:title)).to eq("Error: Login | #{default_title}")
      end
    end
  end

  describe '#my_commodities_page_heading' do
    subject { helper.my_commodities_page_heading(category, total_commodities_count) }

    let(:category) { 'active' }
    let(:total_commodities_count) { 10 }

    context 'when category is active' do
      it { is_expected.to eq('Active commodities: 10') }
    end

    context 'when category is expired' do
      let(:category) { 'expired' }

      it { is_expected.to eq('Expired commodities') }
    end

    context 'when category is invalid' do
      let(:category) { 'invalid' }

      it { is_expected.to eq('Errors from commodity uploads') }
    end
  end
end
