RSpec.describe 'shared/_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/feedback_useful_banner' }

  it { is_expected.to have_text('Give feedback about this service') }
  it { is_expected.to have_text('Tell us about your experience using this service to help us improve it.') }
  it { is_expected.to have_link('Share your feedback', href: 'https://surveys.transformuk.com/s3/17fead99a348') }
end
