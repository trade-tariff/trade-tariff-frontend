require 'spec_helper'

RSpec.describe 'layouts/application', type: :view do
  subject { render }

  before do
    allow(view).to receive(:is_switch_service_banner_enabled?).and_return true

    assign :search, Search.new
  end

  it { is_expected.to have_css 'header.govuk-header .govuk-width-container > .tariff-header-banner' }

  it 'renders the feedback invitation', :aggregate_failures do
    render

    expect(rendered).to have_css('.govuk-feedback')
    expect(rendered).to have_css('.govuk-feedback__title', text: 'Help us improve this service')
    expect(rendered).to have_text('Tell us about your experience using this service.')
    expect(rendered).to have_link('Give us your feedback', href: %r{\A/feedback\?})
  end

  it 'preserves search context in the enquiry link' do
    assign :search, Search.new(request_id: 'search-request-123')

    render

    expect(rendered).to have_link('Enquiry Form', href: '/enquiry_form?request_id=search-request-123')
  end

  context 'when rendering an interactive search page' do
    before { assign(:interactive_search_page, true) }

    it 'uses the feedback invitation', :aggregate_failures do
      render

      expect(rendered).to have_css('.govuk-feedback')
      expect(rendered).not_to have_text('Is this page useful?')
    end
  end

  it 'opts stylesheet tags out of preload link headers' do
    stylesheet_link_calls = []

    allow(view).to receive(:stylesheet_link_tag).and_wrap_original do |method, *args, **kwargs|
      stylesheet_link_calls << [args, kwargs]
      method.call(*args, **kwargs)
    end

    render

    expect(stylesheet_link_calls).to include(
      [[:application], { 'data-turbo-track': 'reload', preload_links_header: false }],
      [[:print], { media: 'print', 'data-turbo-track': 'reload', preload_links_header: false }],
    )
  end
end
