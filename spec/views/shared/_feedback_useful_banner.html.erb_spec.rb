RSpec.describe 'shared/_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/feedback_useful_banner' }

  context 'when on an interactive search page' do
    before do
      assign(:interactive_search_page, true)
    end

    it { is_expected.to have_css('h2', text: 'Give feedback about this service') }
    it { is_expected.to have_text('Tell us about your experience using this service') }

    it { is_expected.to have_link('Share your feedback') }

    it 'opens feedback link in a new tab' do
      render partial: 'shared/feedback_useful_banner'

      expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]')
    end
  end

  context 'when on a standard page' do
    it { is_expected.to have_text('Is this page useful?') }
    it { is_expected.to have_link('Yes') }
    it { is_expected.to have_link('No') }
    it { is_expected.to have_link('Report a problem with this page') }
  end

  context 'when @feedback is set' do
    before do
      assign(:feedback, true)
    end

    it { is_expected.to be_blank }
  end
end
