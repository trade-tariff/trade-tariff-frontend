RSpec.describe LiveIssuesController, type: :controller do
  subject { response }

  before do
    stub_api_request('live_issues')
      .to_return jsonapi_response(:live_issues, live_issues)

    get :index
  end

  let(:live_issues) { attributes_for_list(:live_issue, 2) }

  it { is_expected.to have_http_status(:success) }
  it { is_expected.to render_template(:index) }

  it 'assigns @live_issues', :aggregate_failures do
    expect(assigns(:live_issues)).to be_present
    expect(assigns(:live_issues).length).to eq(2)
    expect(assigns(:live_issues).first).to be_a(LiveIssue)
  end
end
