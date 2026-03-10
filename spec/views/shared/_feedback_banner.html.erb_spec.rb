RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  it { is_expected.to have_css('.govuk-tag', text: 'FEEDBACK') }
  it { is_expected.to have_text('Help us improve this service') }
  it { is_expected.to have_link('give your feedback (opens in new tab)') }

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
