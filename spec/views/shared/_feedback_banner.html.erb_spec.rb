RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  it { is_expected.to have_css('.govuk-tag', text: 'FEEDBACK') }
  it { is_expected.to have_text('Tell us what you think') }
  it { is_expected.to have_link('feedback') }

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
