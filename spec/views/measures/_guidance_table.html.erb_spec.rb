require 'spec_helper'

RSpec.describe 'measures/guidance_table', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'measures/guidance_table', measure_conditions_with_guidance: conditions
  end

  let(:conditions) { build_list :measure_condition, 2, :with_guidance }

  it { is_expected.to have_css 'details summary', text: /Guidance for completing/ }
  it { is_expected.to have_css 'table tbody tr', count: 2 }
  it { is_expected.to have_css 'table tbody td', text: conditions.first.document_code }
  it { is_expected.to have_css 'table tbody td', text: /Guidance CDS/ }
  it { is_expected.to have_css 'table tbody td', text: /Guidance CHIEF/ }

  context 'with no conditions' do
    let(:conditions) { [] }

    it { is_expected.not_to have_css 'details' }
  end
end
