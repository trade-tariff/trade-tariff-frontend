RSpec.describe 'search/_interactive_search_thinking', type: :view do
  it 'passes the boot-loaded messages and timing ranges without parsing YAML on render' do
    allow(Rails.application).to receive(:config_for).with(:guided_search_loading).and_raise('YAML must only be loaded at boot')
    render partial: 'search/interactive_search_thinking'

    panel = Capybara.string(rendered).find('[data-controller="guided-search-loading"]')
    expected = Rails.application.config.guided_search_loading.fetch(:messages).map(&:stringify_keys)
    expect(JSON.parse(panel['data-guided-search-loading-messages-value'])).to eq(expected)
  end

  it 'keeps the decorative bulb outside the single live status region', :aggregate_failures do
    render partial: 'search/interactive_search_thinking'

    panel = Capybara.string(rendered).find('[data-controller="guided-search-loading"]')
    expect(panel).to have_css('[role="status"][aria-live="polite"][aria-atomic="true"]', count: 1)
    expect(panel).to have_css('.app-guided-search-loading__bulb[aria-hidden="true"] svg[aria-hidden="true"][focusable="false"]')
    expect(panel.find('[role="status"]')).not_to have_css('svg')
  end

  it 'escapes configured copy without changing its parsed value', :aggregate_failures do
    messages = [{ text: 'Checking "labels" & <references>', description: 'Product <details>', min_seconds: 1, max_seconds: 3 }]
    allow(Rails.application.config).to receive(:guided_search_loading).and_return(messages:)
    render partial: 'search/interactive_search_thinking'

    panel = Capybara.string(rendered).find('[data-controller="guided-search-loading"]')
    expect(JSON.parse(panel['data-guided-search-loading-messages-value'])).to eq(messages.map(&:stringify_keys))
    expect(rendered).not_to include('<references>')
  end
end
