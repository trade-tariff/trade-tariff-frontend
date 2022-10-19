require 'spec_helper'

RSpec.describe 'measure_type/show', type: :view do
  subject { render }

  before do
    assign :measure_type, measure_type
    assign :preference_code, preference_code
  end

  let(:measure_type) { build :measure_type, id: '103' }
  let(:preference_code) { build :preference_code }

  it { is_expected.to have_css 'h2', text: measure_type.description_only }
  it { is_expected.to have_css 'td', text: measure_type.id }
  it { is_expected.to have_css 'td', text: preference_code.code }
  it { is_expected.to have_css 'td', text: preference_code.description }
  it { is_expected.to have_css 'p', text: /Third country/ }
end
