require 'spec_helper'

RSpec.describe LiveIssuesController, type: :request do
  subject(:perform_request) { get live_issues_path, params: }

  let(:params) { {} }

  before do
    allow(LiveIssue).to receive(:filtered).and_return(build_list(:live_issue, 2))
    perform_request
  end

  it 'renders the live issues page with the default filter state', :aggregate_failures do
    expect(response).to have_http_status(:success)
    expect(response.content_type).to include('text/html')
    expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_desc')
  end

  context 'when supported filters are provided' do
    let(:params) { { sort: 'updated_asc', status: 'active' } }

    it 'normalizes and passes the selected filters to the model' do
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_asc')
    end
  end

  context 'when unsupported filters are provided' do
    let(:params) { { sort: 'sideways', status: %w[active archived] } }

    it 'falls back to the default sort and ignores unsupported statuses' do
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_desc')
    end
  end

  context 'when a non-default sort and both statuses are selected' do
    let(:params) { { sort: 'updated_asc', status: %w[active resolved] } }

    it 'keeps the other filters on each chip remove link', :aggregate_failures do
      document = Capybara.string(response.body)

      expect(document).to have_link(
        'Sort by: Last updated (oldest)',
        href: live_issues_path(status: %w[active resolved]),
      )
      expect(document).to have_link(
        'Status: Active issue',
        href: live_issues_path(sort: 'updated_asc', status: %w[resolved]),
      )
      expect(document).to have_link(
        'Status: Issue resolved',
        href: live_issues_path(sort: 'updated_asc', status: %w[active]),
      )
    end
  end
end
