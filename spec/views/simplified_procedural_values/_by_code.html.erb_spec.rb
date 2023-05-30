require 'spec_helper'

RSpec.describe 'simplified_procedural_values/_by_code', type: :view do
  subject { render }

  let(:spc1) { build(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31') }
  let(:spc2) { build(:simplified_procedural_code_measure, validity_start_date: '2023-02-01', validity_end_date: '2023-02-28') }
  let(:spc3) { build(:simplified_procedural_code_measure, validity_start_date: '2023-03-01', validity_end_date: '2023-03-28') }

  before do
    assign(:simplified_procedural_codes, [spc1, spc2, spc3])
    assign(:simplified_procedural_code, '1.10')
    assign(:goods_nomenclature_label, spc1.goods_nomenclature_label)
    assign(:goods_nomenclature_item_ids, spc1.goods_nomenclature_item_ids)
  end

  it { is_expected.to have_css 'h1', text: 'Simplified procedure value rates for code 1.10 - Pink grapefruit and pomelos' }

  it { is_expected.to have_css 'p', text: 'Applies to commodity code 0805400019, 0805400039.' }

  it { is_expected.to have_css 'td', text: spc1.validity_start_date.to_date.to_formatted_s(:short) }

  it { is_expected.to have_css 'td', text: spc1.validity_end_date.to_date.to_formatted_s(:short) }

  it { is_expected.to have_css 'td', text: spc1.by_code_duty_amount }
end
