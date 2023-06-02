require 'spec_helper'

RSpec.describe 'simplified_procedural_values/_by_code', type: :view do
  subject { render }

  before do
    result = OpenStruct.new(
      measures: [measure],
      simplified_procedural_code: measure.resource_id,
      goods_nomenclature_label: measure.goods_nomenclature_label,
      goods_nomenclature_item_ids: measure.goods_nomenclature_item_ids,
      no_data:,
    )

    assign(:result, result)
  end

  let(:measure) do
    build(
      :simplified_procedural_code_measure,
      validity_start_date: '2023-01-01',
      validity_end_date: '2023-01-31',
    )
  end

  context 'when there is data' do
    let(:no_data) { false }

    it { is_expected.to have_css 'h1', text: 'Simplified procedure value rates for code 1.10 - Pink grapefruit and pomelos' }

    it { is_expected.to have_css 'p', text: 'Applies to commodity code 0805400019, 0805400039.' }

    it { is_expected.to have_css 'td', text: '1 Jan 2023' }

    it { is_expected.to have_css 'td', text: '31 Jan 2023' }

    it { is_expected.to have_css 'td', text: '£67.94' }
  end

  context 'when there is no data' do
    let(:no_data) { true }

    it { is_expected.to have_css 'h1', text: 'Simplified procedure value rates for code 1.10 - Pink grapefruit and pomelos' }

    it { is_expected.to have_css 'p', text: 'No data found for this SPV code' }
  end
end
