require 'spec_helper'

RSpec.describe 'Live issues log', :js, type: :feature do
  let(:active_newer) do
    build(
      :live_issue,
      title: 'Active newer',
      status: 'Active',
      commodities: %w[0806101005 0808309000],
      updated_at: '2026-02-13T12:00:00Z',
    )
  end

  let(:active_older) do
    build(
      :live_issue,
      title: 'Active older',
      status: 'Active',
      commodities: [],
      updated_at: '2026-01-09T12:00:00Z',
    )
  end

  let(:resolved_issue) do
    build(
      :live_issue,
      title: 'Resolved issue',
      status: 'Resolved',
      commodities: [],
      updated_at: '2026-01-01T12:00:00Z',
    )
  end

  let(:live_issues) { [active_newer, resolved_issue, active_older] }

  before do
    allow(LiveIssue).to receive(:all).and_return(live_issues)
  end

  it 'renders card results with the default sort in the active filters summary' do
    visit live_issues_path

    expect(page).to have_content('Live issues log')
    expect(page).to have_css('.govuk-summary-card', count: 3)
    expect(page).to have_no_css('table.govuk-table')
    expect(page).to have_checked_field('Last updated (newest)')
    expect(page).to have_unchecked_field('Active')
    expect(page).to have_css('.live-issues__result-count', text: '3 results')
    expect(page).to have_no_css('.live-issues__showing-count')
    expect(page).to have_css('.live-issues__active-filters-heading', text: 'Active filters and sorting')
    expect(page).to have_css('.live-issues__active-filter', text: 'Sort by: Last updated (newest)')
  end

  it 'applies status filters and last updated sorting through the form' do
    visit live_issues_path

    find('summary', text: 'Filter and sort').click
    choose 'Last updated (oldest)'
    check 'Active'
    click_button 'Apply'

    expect(page).to have_current_path(live_issues_path(sort: 'updated_asc', status: %w[active]), ignore_query: false)
    expect(page).to have_no_css('details.live-issues__filter-panel[open]')
    expect(page).to have_checked_field('Last updated (oldest)')
    expect(page).to have_checked_field('Active')
    expect(page).to have_css('.live-issues__active-filter', text: 'Sort by: Last updated (oldest)')
    expect(page).to have_css('.live-issues__active-filter', text: 'Status: Active issue')
    expect(page).to have_link('Clear all', href: live_issues_path)
    expect(page).to have_css('.govuk-summary-card', count: 2)
    expect(page).to have_css('.govuk-summary-card:first-of-type', text: 'Active older')
    expect(page).to have_no_content('Resolved issue')
  end

  context 'with more than one page of live issues' do
    let(:live_issues) do
      (1..20).map do |index|
        build(
          :live_issue,
          title: "Issue #{index}",
          status: 'Active',
          updated_at: Time.zone.parse("2026-02-#{index.to_s.rjust(2, '0')}").iso8601,
        )
      end
    end

    it 'paginates the card results' do
      visit live_issues_path

      expect(page).to have_css('.live-issues__result-count', text: '20 results')
      expect(page).to have_css('.govuk-summary-card', count: 4)
      expect(page).to have_css('.govuk-pagination')
      expect(page).to have_css('.govuk-pagination__item--ellipsis', text: '⋯')

      click_link 'Next'

      expect(page).to have_current_path(live_issues_path(page: 2), ignore_query: false)
      expect(page).to have_css('.govuk-summary-card', count: 4)
      expect(page).to have_css('.govuk-pagination__item--ellipsis', text: '⋯')
    end
  end
end
