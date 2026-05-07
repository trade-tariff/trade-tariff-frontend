RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  it { is_expected.to have_css('.govuk-tag', text: 'FEEDBACK') }
  it { is_expected.to have_text('Help us improve this service') }
  it { is_expected.to have_link('give your feedback (opens in new tab)') }

  context 'with a custom tag text' do
    subject { render partial: 'shared/feedback_banner', locals: { tag_text: 'BETA' } }

    it { is_expected.to have_css('.govuk-tag', text: 'BETA') }
  end

  it 'opens feedback link in a new tab when not on a subscriptions page' do
    allow(view).to receive_messages(subscriptions_page?: false,
                                    feedback_link_url: 'https://surveys.transformuk.com/s3/17fead99a348?page_context=%2Fsearch')

    render partial: 'shared/feedback_banner'

    expect(rendered).to have_css('a[target="_blank"][rel="noopener"]')
  end

  context 'when on a subscriptions page' do
    before do
      allow(view).to receive_messages(subscriptions_page?: true, feedback_link_url: feedback_path)
    end

    it 'links to the in-app feedback path' do
      render partial: 'shared/feedback_banner'

      expect(rendered).to have_link('give your feedback (opens in new tab)', href: feedback_path)
    end

    it 'does not open the feedback link in a new tab' do
      render partial: 'shared/feedback_banner'

      expect(rendered).not_to have_css('a[target="_blank"]')
    end
  end

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
