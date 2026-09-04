RSpec.describe 'search/_failure_suggestions', type: :view do
  it 'renders nothing without suggestions' do
    render partial: 'search/failure_suggestions', locals: { suggestions: [] }

    expect(rendered).to be_blank
  end

  it 'renders one neutral notification banner', :aggregate_failures do
    render partial: 'search/failure_suggestions', locals: {
      suggestions: ['First suggestion', 'Second suggestion'],
    }

    page = Capybara.string(rendered)
    expect(page).to have_css('.govuk-notification-banner[role="region"]', count: 1)
    expect(page).to have_css('.govuk-notification-banner__title', text: 'Issues with AI-assisted search')
    expect(page).to have_css(
      '.govuk-notification-banner__content .govuk-body',
      text: 'We are aware of some issues affecting AI-assisted search and are working to fix these as soon as possible.',
    )
    expect(page).not_to have_text('First suggestion')
    expect(page).not_to have_text('Second suggestion')
    expect(page).not_to have_css('[role="alert"]')
  end
end
