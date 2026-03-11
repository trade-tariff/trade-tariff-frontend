RSpec.describe 'commodities/_interactive_search_feedback', type: :view do
  subject { render partial: 'commodities/interactive_search_feedback' }

  context 'when request_id is present' do
    before do
      controller.params[:request_id] = 'test-uuid-123'
      allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(true)
    end

    it { is_expected.to have_css('.govuk-inset-text') }
    it { is_expected.to have_css('h2', text: 'Give feedback about this service') }
    it { is_expected.to have_text('Help us improve this service by') }
    it { is_expected.to have_link('giving your feedback (opens in a new tab)') }

    it 'opens feedback link in a new tab' do
      render partial: 'commodities/interactive_search_feedback'

      expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]')
    end

    it 'links to the feedback survey' do
      render partial: 'commodities/interactive_search_feedback'

      expect(rendered).to have_link('giving your feedback (opens in a new tab)', href: 'https://surveys.transformuk.com/s3/17fead99a348')
    end
  end

  context 'when request_id is absent' do
    before do
      controller.params[:request_id] = nil
    end

    it { is_expected.not_to have_css('.govuk-inset-text') }
  end

  context 'when interactive search is disabled' do
    before do
      controller.params[:request_id] = 'test-uuid-123'
      allow(TradeTariffFrontend).to receive(:interactive_search_enabled?).and_return(false)
    end

    it { is_expected.not_to have_css('.govuk-inset-text') }
  end
end
