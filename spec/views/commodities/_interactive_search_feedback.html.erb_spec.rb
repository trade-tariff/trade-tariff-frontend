RSpec.describe 'commodities/_interactive_search_feedback', type: :view do
  subject { render partial: 'commodities/interactive_search_feedback' }

  context 'when request_id is present' do
    before do
      controller.params[:request_id] = 'test-uuid-123'
      allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(true)
    end

    it { is_expected.to have_css('.app-feedback-banner') }
    it { is_expected.to have_css('h2', text: 'Give feedback about this service') }
    it { is_expected.to have_link('Share your feedback') }

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

    it { is_expected.not_to have_css('.app-feedback-banner') }
  end

  context 'when interactive search is disabled' do
    before do
      controller.params[:request_id] = 'test-uuid-123'
      allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(false)
    end

    it { is_expected.not_to have_css('.app-feedback-banner') }
  end
end
