RSpec.describe 'shared/_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/feedback_useful_banner' }

  it { is_expected.to have_text('Is this page useful?') }
  it { is_expected.to have_link('Yes') }
  it { is_expected.to have_link('No') }
  it { is_expected.to have_link('Report a problem with this page') }
end
