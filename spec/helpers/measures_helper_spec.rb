require 'spec_helper'

RSpec.describe MeasuresHelper, type: :helper do
  describe '#filter_duty_expression' do
    subject(:filtered_expression) { helper.filter_duty_expression(measure) }

    let(:measure) { Measure.new(attributes_for(:measure, duty_expression: duty_expression)) }

    context 'when the duty expression is present' do
      let(:duty_expression) { attributes_for(:duty_expression) }

      it { expect(filtered_expression).to eq("80.50 EUR / <abbr title='Hectokilogram'>Hectokilogram</abbr>") }
    end

    context 'when the duty expression is `NIHIL`' do
      let(:duty_expression) { attributes_for(:duty_expression, formatted_base: 'NIHIL') }

      it { expect(filtered_expression).to eq('') }
    end
  end

  describe '#legal_act_regulation_url_link_for' do
    let(:measure) { build(:measure, legal_acts: legal_acts) }

    context 'when there are no legal acts' do
      let(:legal_acts) { [] }

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq('') }
    end

    context 'when the legal act has no regulation url' do
      let(:legal_acts) { [attributes_for(:legal_act, regulation_url: '')] }

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq('') }
    end

    context 'when the legal act has a regulation url' do
      let(:legal_acts) { [attributes_for(:legal_act)] }
      let(:expected_link) do
        '<a target="_blank" rel="noopener norefferer" class="govuk-link" title="The Customs Tariff (Preferential Trade Arrangements) (EU Exit) (Amendment) Regulations 2021" href="https://www.legislation.gov.uk/uksi/2020/1432">S.I. 2020/1432</a>'
      end

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq(expected_link) }
      it { expect(helper.legal_act_regulation_url_link_for(measure)).to be_html_safe }
    end
  end

  describe 'check_how_to_export_goods_link' do
    subject(:link) { check_how_to_export_goods_link(commodity_code: commodity_code, country_code: '', country_name: '', eu_member: eu_member) }

    let(:eu_member) { true }

    context 'when it is a EU member' do
      let(:eu_member) { true }
      let(:commodity_code) { '1234567890' }

      it 'pass in the code as argument' do
        expect(link).to include('pc=1234567890')
      end
    end

    context 'when it is NOT a EU member' do
      let(:eu_member) { false }
      let(:commodity_code) { 'xxxx' }

      it 'does not include params' do
        expect(link).not_to include('pc=')
      end
    end
  end
end
