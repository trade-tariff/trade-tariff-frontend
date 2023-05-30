require 'spec_helper'

RSpec.describe 'simplified_procedural_values/_by_date', type: :view do
  subject { render }

  let(:spc1) { build(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31') }
  let(:spc2) { build(:simplified_procedural_code_measure, validity_start_date: '2023-02-01', validity_end_date: '2023-02-28') }
  let(:spc3) { build(:simplified_procedural_code_measure, validity_start_date: '2023-03-01', validity_end_date: '2023-03-28') }

  before do
    assign(:simplified_procedural_codes, [spc1, spc2, spc3])
    assign(:validity_start_date, spc1.validity_start_date)
    assign(:validity_end_date, spc1.validity_end_date)
    assign(:validity_start_dates, [])
    assign(:by_date_options, [])
  end

  it { is_expected.to have_css '.govuk-heading-s', text: 'Rates for period 1 January 2023 to 31 January 2023' }

  it { is_expected.to have_css 'td', text: spc1.goods_nomenclature_item_ids }

  it { is_expected.to have_css 'td', text: spc1.goods_nomenclature_label }

  it { is_expected.to have_css 'td', text: spc1.duty_amount }
end
