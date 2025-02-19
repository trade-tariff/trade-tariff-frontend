require 'spec_helper'

RSpec.describe 'measures/guidance_table', type: :view do
  subject { render_page && rendered }

  let(:render_page) { render 'measures/guidance_table', measure_conditions_with_guidance: }

  context 'when page includes measures with conditions' do
    let(:measure_conditions_with_guidance) { build_list :measure_condition, 2, :with_guidance }

    it { is_expected.to have_css 'details summary', text: /Guidance for completing/ }
    it { is_expected.to have_css 'table tbody tr', count: 2 }
    it { is_expected.to have_css 'table tbody td', text: measure_conditions_with_guidance.first.document_code }
    it { is_expected.to have_css 'table tbody td', text: /Guidance CDS/ }
  end

  context 'when page includes measures without conditions' do
    let(:measure_conditions_with_guidance) { [] }

    it { is_expected.not_to have_css 'details' }
  end
end
