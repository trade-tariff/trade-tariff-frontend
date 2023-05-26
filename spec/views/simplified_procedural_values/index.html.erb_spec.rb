require 'spec_helper'

RSpec.describe 'simplified_procedural_values/index', type: :view do
  subject { render }

  let(:simplified_procedural_code_measure) { build(:simplified_procedural_code_measure) }

  before do
    assign(:simplified_procedural_codes, [])
    assign(:validity_start_date, simplified_procedural_code_measure.validity_start_date)
    assign(:validity_end_date, simplified_procedural_code_measure.validity_end_date)
    assign(:validity_start_dates, [])
    assign(:by_date_options, [])
  end

  context 'when code instance variable is set' do
    context 'when true' do
      before { assign(:by_code, true) }

      it { is_expected.to render_template('simplified_procedural_values/_by_code') }
      it { is_expected.to render_template('simplified_procedural_values/_sidebar') }
    end

    context 'when false' do
      before { assign(:by_code, false) }

      it { is_expected.to render_template('simplified_procedural_values/_by_date') }
      it { is_expected.to render_template('simplified_procedural_values/_sidebar') }
    end
  end
end
