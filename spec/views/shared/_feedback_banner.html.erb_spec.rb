RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  it { is_expected.to have_css('.govuk-tag', text: 'FEEDBACK') }
  it { is_expected.to have_text('Tell us what you think') }
  it { is_expected.to have_link('feedback', href: %r{\A/feedback\?}) }

  context 'with a custom tag text' do
    subject { render partial: 'shared/feedback_banner', locals: { tag_text: 'BETA' } }

    it { is_expected.to have_css('.govuk-tag', text: 'BETA') }
  end

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
