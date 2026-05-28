RSpec.describe LiveIssuesController, type: :controller do
  subject(:perform_request) { get :index, params: params }

  let(:params) { {} }
  let(:filtered_live_issues) { build_list(:live_issue, 2) }

  before do
    allow(LiveIssue).to receive(:filtered).and_return(filtered_live_issues)
    perform_request
  end

  it 'returns a successful response' do
    expect(response).to have_http_status(:success)
  end

  it 'renders the index template' do
    expect(response).to render_template(:index)
  end

  it 'assigns filtered live issues with default filter state', :aggregate_failures do
    expect(assigns(:live_issues).to_a).to eq(filtered_live_issues)
    expect(assigns(:live_issues_count)).to eq(2)
    expect(assigns(:sort)).to eq('updated_desc')
    expect(assigns(:applied_sort)).to be_nil
    expect(assigns(:status_filters)).to eq([])
    expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_desc')
  end

  context 'when sorting by oldest updated first' do
    let(:params) { { sort: 'updated_asc' } }

    it 'passes the sort to the model', :aggregate_failures do
      expect(assigns(:sort)).to eq('updated_asc')
      expect(assigns(:applied_sort)).to eq('updated_asc')
      expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_asc')
    end
  end

  context 'when filtering by status' do
    let(:params) { { status: %w[active resolved] } }

    it 'passes selected statuses to the model', :aggregate_failures do
      expect(assigns(:status_filters)).to eq(%w[active resolved])
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active resolved], sort: 'updated_desc')
    end
  end

  context 'when a single status value is provided' do
    let(:params) { { status: 'active' } }

    it 'normalizes the status to an array', :aggregate_failures do
      expect(assigns(:status_filters)).to eq(%w[active])
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_desc')
    end
  end

  context 'when unknown filter values are provided' do
    let(:params) { { sort: 'sideways' } }

    it 'falls back to default filter state', :aggregate_failures do
      expect(assigns(:sort)).to eq('updated_desc')
      expect(assigns(:applied_sort)).to be_nil
      expect(assigns(:status_filters)).to eq([])
      expect(LiveIssue).to have_received(:filtered).with(statuses: [], sort: 'updated_desc')
    end
  end

  context 'when unknown status filters are provided' do
    let(:params) { { status: %w[active archived] } }

    it 'ignores unsupported statuses', :aggregate_failures do
      expect(assigns(:status_filters)).to eq(%w[active])
      expect(LiveIssue).to have_received(:filtered).with(statuses: %w[active], sort: 'updated_desc')
    end
  end
end
