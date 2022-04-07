require 'spec_helper'

RSpec.describe MeasureConditionDialog do
  subject(:dialog) { described_class.build(declarable, measure) }

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
  end

  describe '#build' do
    let(:declarable) { build(:commodity, goods_nomenclature_item_id:) }

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
        expected_options = {
          partial: 'measures/measure_condition_modal_augmented',
          locals: {
            modal_content_file: 'measures/measure_condition_replacement_modals/animal_health',
            measure:,
          },
        }

        expect(dialog.options).to eq(expected_options)
      end
    end

    context 'when matching replacing config' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { '306' }

      it 'returns the replacing modal partial options' do
        expected_options = {
          partial: 'measures/measure_condition_replacement_modals/small_brewers_relief_440',
        }

        expect(dialog.options).to eq(expected_options)
      end
    end

    context 'when matching no config' do
      let(:goods_nomenclature_item_id) { '2203000100' }
      let(:additional_code) { 'X440' }
      let(:measure_type_id) { 'foo' }

      it 'returns the default modal partial options' do
        expected_options = {
          partial: 'measures/measure_condition_modal_default',
          locals: { measure: },
        }

        expect(dialog.options).to eq(expected_options)
      end
    end
  end
end
