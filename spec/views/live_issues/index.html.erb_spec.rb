require 'spec_helper'

RSpec.describe 'live_issues/index', type: :view do
  subject(:rendered_page) { Capybara.string(rendered) }

  let(:live_issues) { [active_issue, resolved_issue] }
  let(:live_issues_count) { live_issues.size }
  let(:sort) { 'updated_desc' }
  let(:applied_sort) { 'updated_desc' }
  let(:status_filters) { %w[active] }

  let(:active_issue) do
    build(
      :live_issue,
      title: 'Missing Japan Preference',
      description: 'The **DCTS** measure was deleted.',
      suggested_action: 'Declare the **MFN** rate.',
      commodities: %w[0806101005 0808309000],
      status: 'Active issue',
      date_discovered: Time.zone.parse('2026-01-06'),
      date_resolved: nil,
      updated_at: Time.zone.parse('2026-02-13'),
    )
  end

  let(:resolved_issue) do
    build(
      :live_issue,
      title: 'DCTS Deleted Measure',
      description: 'Resolved issue description.',
      suggested_action: 'None',
      commodities: [],
      status: 'Resolved',
      date_discovered: Time.zone.parse('2025-12-01'),
      date_resolved: Time.zone.parse('2026-01-01'),
      updated_at: Time.zone.parse('2026-01-02'),
    )
  end

  before do
    assign :live_issues, Kaminari.paginate_array(live_issues, total_count: live_issues_count).page(1).per(4)
    assign :live_issues_count, live_issues_count
    assign :sort, sort
    assign :applied_sort, applied_sort
    assign :status_filters, status_filters

    render
  end

  it 'renders the live issues heading' do
    expect(rendered_page).to have_css('h1', text: 'Live issues log')
  end

  it 'renders a filter and sort form', :aggregate_failures do
    expect(rendered_page).to have_css('details.live-issues__filter-panel summary', text: 'Filter and sort')
    expect(rendered_page).to have_css('.live-issues__result-count', text: '2 results')
    expect(rendered_page).to have_css('form[action="/live_issues"][method="get"]')
    expect(rendered_page).to have_field('Last updated (newest)', type: 'radio', checked: true)
    expect(rendered_page).to have_field('Last updated (oldest)', type: 'radio', checked: false)
    expect(rendered_page).to have_field('Active', type: 'checkbox', checked: true)
    expect(rendered_page).to have_field('Resolved', type: 'checkbox', checked: false)
  end

  it 'renders applied filter tags', :aggregate_failures do
    expect(rendered_page).to have_css('.live-issues__active-filter', text: '× Sort by: Last updated (newest)')
    expect(rendered_page).to have_css('.live-issues__active-filter', text: 'Status: Active issue')
    expect(rendered_page).to have_link('Clear filters', href: live_issues_path)
  end

  it 'renders live issues as summary cards', :aggregate_failures do
    expect(rendered_page).to have_no_css('table.govuk-table')
    expect(rendered_page).to have_css('.govuk-summary-card', count: 2)
    expect(rendered_page).to have_css('.govuk-summary-card__title', text: 'Missing Japan Preference')
    expect(rendered_page).to have_css('.live-issues__card-meta', text: 'Last updated: 13 February 2026')
    expect(rendered_page).to have_css('.live-issues__card-issue', text: 'Issue: Missing Japan Preference')
    expect(rendered_page).to have_css('.govuk-summary-list__key', text: 'Description')
    expect(rendered_page).to have_css('.govuk-summary-list__key', text: 'Commodities affected')
    expect(rendered_page).to have_css('.govuk-summary-list__key', text: 'Status')
    expect(rendered_page).to have_css('.govuk-summary-list__key', text: 'Recommendation')
    expect(rendered_page).to have_css('.govuk-summary-list__key', text: 'Date of effect')
    expect(rendered_page).to have_css('.govuk-tag--green', text: 'Issue resolved')
  end

  it 'renders markdown content inside card values', :aggregate_failures do
    expect(rendered_page).to have_css('.govuk-summary-list__value strong', text: 'DCTS')
    expect(rendered_page).to have_css('.govuk-summary-list__value strong', text: 'MFN')
  end

  it 'keeps progressive disclosure for multiple commodities', :aggregate_failures do
    expect(rendered_page).to have_css('.govuk-details__summary-text', text: '2 commodities')
    expect(rendered_page).to have_css('.live-issues__commodity-list')
  end

  it 'renders the commodities partial' do
    expect(view).to render_template(partial: 'live_issues/_commodities')
  end

  context 'when there are no live issues after filtering' do
    let(:live_issues) { [] }
    let(:live_issues_count) { 0 }
    let(:applied_sort) { nil }
    let(:status_filters) { %w[resolved] }

    it 'renders an empty state' do
      expect(rendered_page).to have_css('.govuk-body', text: 'No live issues match the selected filters.')
    end
  end
end
