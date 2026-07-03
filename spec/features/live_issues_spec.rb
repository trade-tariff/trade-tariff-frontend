require 'spec_helper'

RSpec.describe 'Live issues log', :js, type: :feature do
  let(:live_issues) do
    (1..20).map do |index|
      build(
        :live_issue,
        title: "Issue #{index}",
        status: index.even? ? 'Active' : 'Resolved',
        updated_at: Time.zone.parse("2026-02-#{index.to_s.rjust(2, '0')}").iso8601,
      )
    end
  end

  before { allow(LiveIssue).to receive(:all).and_return(live_issues) }

  it 'renders, paginates, filters and sorts card results', :aggregate_failures do
    visit live_issues_path

    expect(page).to have_css('.app-c-filter__count', text: '20 results')
    expect(page).to have_css('.govuk-summary-card', count: 4)
    expect(page).to have_no_css('.app-c-selected-filters')
    expect(page).to have_css('.govuk-pagination__item--ellipsis', text: '⋯')

    find('summary', text: 'Filter and sort').click
    choose 'Last updated (oldest)'
    check 'Active'
    click_button 'Apply'

    expect(page).to have_current_path(live_issues_path(sort: 'updated_asc', status: %w[active]), ignore_query: false)
    expect(page).to have_no_css('details.live-issues__filter-panel[open]')
    expect(page).to have_css('.app-c-selected-filters__tag', text: 'Sort by: Last updated (oldest)')
    expect(page).to have_css('.app-c-selected-filters__tag', text: 'Status: Active issue')
    expect(page).to have_css('.govuk-summary-card:first-of-type', text: 'Issue 2')
    expect(page).to have_no_content('Issue 1')
  end

  it 'renders live issue commodity links when a commodity code includes non-digit characters' do
    allow(LiveIssue).to receive(:all).and_return([
      build(:live_issue, commodities: ['3402420090,', '7222190000']),
    ])

    visit live_issues_path

    expect(page).to have_link('3402420090', href: commodity_path('3402420090'))
    expect(page).to have_link('7222190000', href: commodity_path('7222190000'))
  end

  it 'renders invalid live issue commodity values as text' do
    allow(LiveIssue).to receive(:all).and_return([
      build(:live_issue, commodities: %w[BAD]),
    ])

    visit live_issues_path

    expect(page).to have_content('BAD')
    expect(page).to have_no_link('BAD')
  end

  it 'renders none when live issue commodities are nil or blank' do
    allow(LiveIssue).to receive(:all).and_return([
      build(:live_issue, commodities: nil),
      build(:live_issue, commodities: [nil, '', ' ']),
    ])

    visit live_issues_path

    expect(page).to have_css('.govuk-summary-list__row', text: 'Commodities affected None', count: 2)
  end
end
