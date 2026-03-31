RSpec.describe LiveIssuesController, type: :controller do
  subject(:perform_request) { get :index, params: params }

  let(:params) { {} }
  let(:live_issues) do
    [
      attributes_for(:live_issue, title: 'Resolved newer', status: 'Resolved', updated_at: '2025-07-16T12:00:00Z'),
      attributes_for(:live_issue, title: 'Active older', status: 'Active', updated_at: '2025-07-14T12:00:00Z'),
      attributes_for(:live_issue, title: 'Resolved older', status: 'Resolved', updated_at: '2025-07-13T12:00:00Z'),
      attributes_for(:live_issue, title: 'Active newer', status: 'Active', updated_at: '2025-07-15T12:00:00Z'),
    ]
  end

  before do
    stub_api_request('live_issues')
      .to_return jsonapi_response(:live_issues, live_issues)

    perform_request
  end

  it 'returns a successful response' do
    expect(response).to have_http_status(:success)
  end

  it 'renders the index template' do
    expect(response).to render_template(:index)
  end

  it 'assigns live issues sorted with active issues first and updated_at descending', :aggregate_failures do
    expect(assigns(:live_issues)).to all(be_a(LiveIssue))
    expect(assigns(:live_issues).map(&:title)).to eq([
      'Active newer',
      'Active older',
      'Resolved newer',
      'Resolved older',
    ])
    expect(assigns(:sort_direction)).to eq('asc')
  end

  context 'when sorting the status column descending' do
    let(:params) { { sort: 'desc' } }

    it 'moves active issues to the end and still sorts updated_at descending within each status', :aggregate_failures do
      expect(assigns(:live_issues).map(&:title)).to eq([
        'Resolved newer',
        'Resolved older',
        'Active newer',
        'Active older',
      ])
      expect(assigns(:sort_direction)).to eq('desc')
    end
  end

  context 'when an unknown sort direction is provided' do
    let(:params) { { sort: 'sideways' } }

    it 'falls back to the default status sort' do
      expect(assigns(:live_issues).map(&:title)).to eq([
        'Active newer',
        'Active older',
        'Resolved newer',
        'Resolved older',
      ])
    end
  end
end
