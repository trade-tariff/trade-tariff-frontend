require 'spec_helper'

RSpec.describe 'feedback/thanks', type: :view do
  subject { render }

  let(:feedback) { build(:feedback) }

  it { is_expected.not_to have_css 'a', text: 'Return to page' }

  context 'with referrer link present' do
    before do
      assign :referrer, feedback.referrer
    end

    it { is_expected.to have_css 'a', text: 'Return to page' }
    it { is_expected.to have_link nil, href: feedback.referrer }
  end
end
