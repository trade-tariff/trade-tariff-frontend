RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  it { is_expected.to have_css('.govuk-tag', text: 'SERVICE UPDATE') }
  it { is_expected.to have_text('We’re making improvements to this service. Let us know what you think by giving your feedback.') }
  it { is_expected.to have_link('feedback', href: %r{\A/feedback\?}) }

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
