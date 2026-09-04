RSpec.describe 'search/_failure_suggestions', type: :view do
  it 'renders nothing without suggestions' do
    render partial: 'search/failure_suggestions', locals: { suggestions: [] }

    expect(rendered).to be_blank
  end

  it 'renders all suggestions in one non-alert inset', :aggregate_failures do
    render partial: 'search/failure_suggestions', locals: {
      suggestions: ['First suggestion', 'Second suggestion'],
    }

    page = Capybara.string(rendered)
    expect(page).to have_css('.govuk-inset-text', count: 1)
    expect(page).to have_css('strong', text: 'About these results')
    expect(page).to have_text('First suggestion').and have_text('Second suggestion')
    expect(page).not_to have_css('[role="alert"]')
  end
end
