require 'spec_helper'

RSpec.describe 'simplified_procedural_values/_by_date', type: :view do
  subject { render }

  let(:measure) { build(:simplified_procedural_code_measure, validity_start_date: '2023-01-01', validity_end_date: '2023-01-31') }

  before do
    result = OpenStruct.new(
      measures: [measure],
      validity_start_date: measure.validity_start_date,
      validity_end_date: measure.validity_end_date,
      validity_start_dates: [],
      by_date_options: [],
    )

    assign(:result, result)
  end

  it { is_expected.to have_css '.govuk-heading-s', text: 'Rates for period 1 January 2023 to 31 January 2023' }

  it { is_expected.to have_css 'td', text: measure.goods_nomenclature_item_ids }

  it { is_expected.to have_css 'td', text: measure.goods_nomenclature_label }

  it { is_expected.to have_css 'td', text: measure.duty_amount }
end
