RSpec.describe 'commodities/_interactive_search_feedback', type: :view do
  subject { render partial: 'commodities/interactive_search_feedback' }

  context 'when request_id is present' do
    before do
      controller.params[:request_id] = 'test-uuid-123'
    end

    it { is_expected.to have_css('.govuk-notification-banner') }
    it { is_expected.to have_text('You arrived at this page using our guided search') }
    it { is_expected.to have_link('Tell us if this was the right commodity code (opens in new tab)') }

    it 'opens feedback link in a new tab' do
      render partial: 'commodities/interactive_search_feedback'

      expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]')
    end

    it 'passes request_id to the feedback form' do
      render partial: 'commodities/interactive_search_feedback'

      expect(rendered).to have_link(href: /request_id=test-uuid-123/)
    end
  end

  context 'when request_id is absent' do
    before do
      controller.params[:request_id] = nil
    end

    it { is_expected.not_to have_css('.govuk-notification-banner') }
  end
end
