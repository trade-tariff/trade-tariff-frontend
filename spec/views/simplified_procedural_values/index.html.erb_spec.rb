require 'spec_helper'

RSpec.describe 'simplified_procedural_values/index', type: :view do
  subject { render }

  let(:measure) { build(:simplified_procedural_code_measure) }

  before do
    result = OpenStruct.new(
      measures: [measure],
      goods_nomenclature_label: measure.goods_nomenclature_label,
      goods_nomenclature_item_ids: measure.goods_nomenclature_item_ids,
      validity_start_date: measure.validity_start_date,
      validity_end_date: measure.validity_end_date,
      validity_start_dates: [],
      by_code:,
      no_data: false,
      simplified_procedural_code: measure.resource_id,
      by_date_options: [],
    )

    assign(:result, result)
  end

  context 'when the result shows we are filtering by code' do
    let(:by_code) { true }

    it { is_expected.to render_template('simplified_procedural_values/_by_code') }
    it { is_expected.to render_template('simplified_procedural_values/_sidebar') }
  end

  context 'when the result shows we are filtering by date' do
    let(:by_code) { false }

    it { is_expected.to render_template('simplified_procedural_values/_by_date') }
    it { is_expected.to render_template('simplified_procedural_values/_sidebar') }
  end
end
