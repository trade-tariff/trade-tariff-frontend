RSpec.describe LiveIssuesController, type: :controller do
  subject(:perform_request) { get :index, params: params }

  let(:params) { {} }
  let(:sorted_live_issues) { build_list(:live_issue, 2) }

  before do
    allow(LiveIssue).to receive(:sorted_by_status).and_return(sorted_live_issues)
    perform_request
  end

  it 'returns a successful response' do
    expect(response).to have_http_status(:success)
  end

  it 'renders the index template' do
    expect(response).to render_template(:index)
  end

  it 'assigns the sorted live issues with the default sort direction', :aggregate_failures do
    expect(assigns(:live_issues)).to eq(sorted_live_issues)
    expect(assigns(:sort_direction)).to eq('asc')
    expect(LiveIssue).to have_received(:sorted_by_status).with('asc')
  end

  context 'when sorting the status column descending' do
    let(:params) { { sort: 'desc' } }

    it 'passes the descending sort direction to the model', :aggregate_failures do
      expect(assigns(:live_issues)).to eq(sorted_live_issues)
      expect(assigns(:sort_direction)).to eq('desc')
      expect(LiveIssue).to have_received(:sorted_by_status).with('desc')
    end
  end

  context 'when an unknown sort direction is provided' do
    let(:params) { { sort: 'sideways' } }

    it 'falls back to the default status sort', :aggregate_failures do
      expect(assigns(:live_issues)).to eq(sorted_live_issues)
      expect(assigns(:sort_direction)).to eq('asc')
      expect(LiveIssue).to have_received(:sorted_by_status).with('asc')
    end
  end
end
