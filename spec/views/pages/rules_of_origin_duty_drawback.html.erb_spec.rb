require 'spec_helper'

RSpec.describe 'pages/rules_of_origin_duty_drawback', type: :view do
  subject { render && rendered }

  before { assign :schemes, schemes }

  let(:schemes) { build_list :rules_of_origin_scheme, 3 }

  context 'when origin reference document exits for all schemes' do
    it { is_expected.to have_css 'a[href]', text: /View agreement details/, count: 3 }

    it { is_expected.to have_css 'a[href]', text: /View origin reference document/, count: 3 }
  end

  context 'when origin reference document only exists for 2 schemes' do
    before { schemes.first.origin_reference_document.ord_original = nil }

    it { is_expected.to have_css 'a[href]', text: /View agreement details/, count: 3 }

    it { is_expected.to have_css 'a[href]', text: /View origin reference document/, count: 2 }
  end
end
