RSpec.describe 'shared/_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/feedback_useful_banner' }

  it { is_expected.to have_text('Give feedback about this service') }
  it { is_expected.to have_text('Tell us about your experience using this service to help us improve it.') }
  it { is_expected.to have_link('Share your feedback', href: %r{\Ahttps://surveys\.transformuk\.com/s3/17fead99a348\?page_context=}) }

  it 'does not render a divider by default' do
    render partial: 'shared/feedback_useful_banner'

    expect(rendered).not_to have_css('.feedback-useful-banner__divider')
  end

  it 'can render the guided search divider using the standard feedback banner', :aggregate_failures do
    render partial: 'shared/feedback_useful_banner', locals: { show_divider: true }

    expect(rendered).to have_css('.feedback-useful-banner')
    expect(rendered).to have_css('.feedback-useful-banner__divider')
    expect(rendered).not_to have_css('.app-feedback-useful-banner')
  end
end
