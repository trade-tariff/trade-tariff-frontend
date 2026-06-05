RSpec.describe 'shared/_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/feedback_useful_banner' }

  it { is_expected.to have_text('Is this page useful?') }
  it { is_expected.to have_link('Yes', href: %r{\A/feedback\?.*page_useful=yes}) }
  it { is_expected.to have_link('No', href: %r{\A/feedback\?.*page_useful=no}) }
  it { is_expected.to have_link('Report a problem with this page', href: %r{\A/feedback\?}) }

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
