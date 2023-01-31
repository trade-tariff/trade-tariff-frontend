require 'spec_helper'

RSpec.describe 'commodities/_additional_code_table', type: :view do
  subject(:rendered_page) do
    render 'commodities/additional_code_table', measures: [measure, measure]
    rendered
  end

  let(:measure) { build :measure, :vat, :with_additional_code }

  it { is_expected.to have_css '#additional-code', text: /[a-zA-Z\d]{4}/i }
  it { is_expected.to have_css '.additional-code-table', text: /100 kg/ }
end
