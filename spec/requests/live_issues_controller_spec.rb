require 'spec_helper'

RSpec.describe LiveIssuesController, type: :request do
  subject(:perform_request) { get live_issues_path, params: params }

  let(:params) { {} }
  let(:filtered_live_issues) { build_list(:live_issue, 2) }
  let(:rendered_page) { Capybara.string(response.body) }

  before do
    allow(LiveIssue).to receive(:filtered).and_return(filtered_live_issues)
    perform_request
  end

  it 'returns a successful HTML response', :aggregate_failures do
    expect(response).to have_http_status(:success)
    expect(response.content_type).to include('text/html')
    expect(rendered_page).to have_css('h1', text: 'Live issues log')
  end

  it 'requests live issues with default filter state', :aggregate_failures do
    expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_desc')
    expect(rendered_page).to have_checked_field('Last updated (newest)')
    expect(rendered_page).to have_no_css('.live-issues__active-filters')
  end

  context 'when sorting by oldest updated first' do
    let(:params) { { sort: 'updated_asc' } }

    it 'passes the sort to the model and renders the applied sort chip', :aggregate_failures do
      expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_asc')
      expect(rendered_page).to have_checked_field('Last updated (oldest)')
      expect(rendered_page).to have_css('.live-issues__active-filter', text: 'Sort by: Last updated (oldest)')
    end
  end

  context 'when filtering by status' do
    let(:params) { { status: %w[active resolved] } }

    it 'passes selected statuses to the model and keeps the checkboxes selected', :aggregate_failures do
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active resolved], sort: 'updated_desc')
      expect(rendered_page).to have_checked_field('Active')
      expect(rendered_page).to have_checked_field('Resolved')
    end
  end

  context 'when a single status value is provided' do
    let(:params) { { status: 'active' } }

    it 'normalizes the status to an array', :aggregate_failures do
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_desc')
      expect(rendered_page).to have_checked_field('Active')
    end
  end

  context 'when unknown filter values are provided' do
    let(:params) { { sort: 'sideways' } }

    it 'falls back to default filter state', :aggregate_failures do
      expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_desc')
      expect(rendered_page).to have_checked_field('Last updated (newest)')
      expect(rendered_page).to have_no_css('.live-issues__active-filters')
    end
  end

  context 'when unknown status filters are provided' do
    let(:params) { { status: %w[active archived] } }

    it 'ignores unsupported statuses', :aggregate_failures do
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_desc')
      expect(rendered_page).to have_checked_field('Active')
      expect(rendered_page).to have_no_field('Archived')
    end
  end
end
