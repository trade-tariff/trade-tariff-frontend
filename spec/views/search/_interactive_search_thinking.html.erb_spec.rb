RSpec.describe 'search/_interactive_search_thinking', type: :view do
  it 'passes the configured messages and timing ranges to the waiting controller' do
    render partial: 'search/interactive_search_thinking'

    panel = Capybara.string(rendered).find('[data-controller="guided-search-loading"]')
    expected = Rails.application.config_for(:guided_search_loading).fetch(:messages).map(&:stringify_keys)
    expect(JSON.parse(panel['data-guided-search-loading-messages-value'])).to eq(expected)
  end

  it 'escapes configured copy without changing its parsed value', :aggregate_failures do
    messages = [{ text: 'Checking "labels" & <references>', description: 'Product <details>', min_seconds: 1, max_seconds: 3 }]
    allow(Rails.application).to receive(:config_for).with(:guided_search_loading).and_return(messages:)
    render partial: 'search/interactive_search_thinking'

    panel = Capybara.string(rendered).find('[data-controller="guided-search-loading"]')
    expect(JSON.parse(panel['data-guided-search-loading-messages-value'])).to eq(messages.map(&:stringify_keys))
    expect(rendered).not_to include('<references>')
  end
end
