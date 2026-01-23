RSpec.shared_examples 'an invalid commodity file upload' do |fixture_path, content_type|
  let(:invalid_file) { fixture_file_upload(fixture_path, content_type) }

  before do
    token = 'valid-jwt-token'
    cookies[:id_token] = token
    allow(User).to receive(:find).and_return(user)
    allow(Subscription).to receive(:find).and_return(subscription)

    post :create, params: { myott_commodity_upload_form: { file: invalid_file } }
  end

  it 'adds an error to the form' do
    expect(assigns(:upload_form).errors[:file]).to include('Selected file has no valid commodity codes in column A')
  end

  it 'renders the new template again' do
    expect(response).to render_template(:new)
  end
end
