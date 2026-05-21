require 'spec_helper'

RSpec.describe 'layouts/application', type: :view do
  subject { render }

  before do
    allow(view).to receive(:is_switch_service_banner_enabled?).and_return true

    assign :search, Search.new
  end

  it { is_expected.to have_css 'header.govuk-header .govuk-width-container > .tariff-header-banner' }

  it 'renders the standard feedback useful banner', :aggregate_failures do
    render

    expect(rendered).to have_css('.feedback-useful-banner')
    expect(rendered).not_to have_css('.app-feedback-useful-banner')
  end

  context 'when rendering an interactive search page' do
    before { assign(:interactive_search_page, true) }

    it 'uses the standard feedback useful banner with a divider', :aggregate_failures do
      render

      expect(rendered).to have_css('.feedback-useful-banner')
      expect(rendered).to have_css('.feedback-useful-banner__divider')
      expect(rendered).not_to have_css('.app-feedback-useful-banner')
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
