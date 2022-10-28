require 'spec_helper'

RSpec.describe 'measures/guidance_table', type: :view do
  subject { render_page && rendered }

  let(:render_page) { render 'measures/guidance_table', measure_conditions_with_guidance:, anchor: }

  context 'when the page anchor is `export`' do
    let(:measure_conditions_with_guidance) { build_list :measure_condition, 2, :with_guidance }
    let(:anchor) { 'export' }

    it { is_expected.to have_css 'details summary', text: /Guidance for completing/ }
    it { is_expected.to have_css 'table tbody tr', count: 2 }
    it { is_expected.to have_css 'table tbody td', text: measure_conditions_with_guidance.first.document_code }
    it { is_expected.to have_css 'table tbody td', text: /Guidance CDS/ }
    it { is_expected.to have_css 'table tbody td', text: /Guidance CHIEF/ }

    context 'with no conditions' do
      let(:measure_conditions_with_guidance) { [] }

      it { is_expected.not_to have_css 'details' }
    end
  end

  context 'when the page anchor is `import`' do
    let(:measure_conditions_with_guidance) { build_list :measure_condition, 2, :with_guidance }
    let(:anchor) { 'import' }

    it { is_expected.to have_css 'details summary', text: /Guidance for completing/ }
    it { is_expected.to have_css 'table tbody tr', count: 2 }
    it { is_expected.to have_css 'table tbody td', text: measure_conditions_with_guidance.first.document_code }
    it { is_expected.to have_css 'table tbody td', text: /Guidance CDS/ }
    it { is_expected.not_to have_css 'table tbody td', text: /Guidance CHIEF/ }

    context 'with no conditions' do
      let(:measure_conditions_with_guidance) { [] }

      it { is_expected.not_to have_css 'details' }
    end
  end
end
