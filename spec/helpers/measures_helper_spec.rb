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

  describe '#modal_partial_options_for' do
    let(:declarable) { build(:commodity, goods_nomenclature_item_id: goods_nomenclature_item_id) }

    let(:measure) do
      build(
        :measure,
        measure_type: attributes_for(
          :measure_type,
          id: measure_type_id,
        ),
        additional_code: attributes_for(
          :additional_code,
          code: additional_code,
        ),
      )
    end

    context 'when matching augmenting config' do
      let(:goods_nomenclature_item_id) { '0101210000' }
      let(:additional_code) { nil } # Translates to NullObject in Measure#additional_code
      let(:measure_type_id) { '350' }

      it 'returns the augmenting modal partial options' do
        options = helper.modal_partial_options_for(declarable, measure)
        expected_options = {
          partial: 'measure_condition_modal_augment',
          locals: { modal_content_file: 'animal_health' },
        }

        expect(options).to eq(expected_options)
      end
    end

    context 'when matching replacing config' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { '306' }

      it 'returns the replacing modal partial options' do
        options = helper.modal_partial_options_for(declarable, measure)
        expected_options = {
          partial: 'measure_condition_replacement_modals/small_breweries_relief_440',
        }

        expect(options).to eq(expected_options)
      end
    end

    context 'when matching no config' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { 'foo' }

      it 'returns the default modal partial options' do
        options = helper.modal_partial_options_for(declarable, measure)
        expected_options = {
          partial: 'measure_condition_modal_default',
          locals: { measure: measure },
        }

        expect(options).to eq(expected_options)
      end
    end
  end

  describe '#config_for' do
    context 'when a match is found' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { '306' }

      it 'returns the correct modal config' do
        config = helper.config_for(goods_nomenclature_item_id, additional_code, measure_type_id)
        expected_config = {
          'goods_nomenclature_item_id' => '2203000100',
          'additional_code' => 'X440',
          'measure_type_id' => '306',
          'content_file' => 'small_breweries_relief_440',
          'overwrite' => true,
        }

        expect(config).to eq(expected_config)
      end
    end

    context 'when a match is not found' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { 'foo' }

      it 'returns the correct modal config' do
        config = helper.config_for(goods_nomenclature_item_id, additional_code, measure_type_id)
        expected_config = { content_file: nil, overwrite: nil }

        expect(config).to eq(expected_config)
      end
    end
  end
end
