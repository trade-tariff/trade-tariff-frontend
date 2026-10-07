RSpec.describe 'shared/_feedback_invitation', type: :view do
  subject { render partial: 'shared/feedback_invitation' }

  it { is_expected.to have_css('.govuk-feedback__title', text: 'Help us improve this service') }
  it { is_expected.to have_css('.govuk-feedback__body > p', count: 1) }
  it { is_expected.to have_text('Tell us about your experience using this service.') }
  it { is_expected.to have_link('Give us your feedback', href: %r{\A/feedback\?}) }
  it { is_expected.not_to have_text('Is this page useful?') }
  it { is_expected.not_to have_link('Report a problem with this page') }
end
