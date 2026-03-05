RSpec.describe 'shared/_feedback_banner', type: :view do
  subject { render partial: 'shared/feedback_banner' }

  context 'when on an interactive search page' do
    before do
      assign(:interactive_search_page, true)
    end

    it { is_expected.to have_css('.govuk-tag', text: 'BETA') }
    it { is_expected.to have_text('Help us improve this service') }

    it { is_expected.to have_link('give your feedback') }

    it 'opens feedback link in a new tab' do
      render partial: 'shared/feedback_banner'

      expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]')
    end
  end

  context 'when on a standard page' do
    it { is_expected.to have_css('.govuk-tag', text: 'FEEDBACK') }
    it { is_expected.to have_text('Tell us what you think') }
    it { is_expected.to have_link('feedback') }
  end

  context 'when @feedback is set' do
    before do
      assign(:feedback, true)
    end

    it { is_expected.to be_blank }
  end
end
