RSpec.describe 'shared/_interactive_feedback_useful_banner', type: :view do
  subject { render partial: 'shared/interactive_feedback_useful_banner' }

  it { is_expected.to have_css('h2', text: 'Give feedback about this service') }
  it { is_expected.to have_text('Tell us about your experience using this service') }
  it { is_expected.to have_link('Share your feedback') }

  it 'opens feedback link in a new tab' do
    render partial: 'shared/interactive_feedback_useful_banner'

    expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]')
  end

  context 'when @feedback is set' do
    before { assign(:feedback, true) }

    it { is_expected.to be_blank }
  end
end
