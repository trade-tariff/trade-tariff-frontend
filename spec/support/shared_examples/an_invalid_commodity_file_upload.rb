RSpec.shared_examples 'an invalid commodity file upload' do |fixture_path, content_type|
  let(:invalid_file) { fixture_file_upload(fixture_path, content_type) }

  before do
    token = 'valid-jwt-token'
    cookies[:id_token] = token
    allow(User).to receive(:find).and_return(user)
    allow(Subscription).to receive(:find).and_return(subscription)

    post :create, params: { fileUpload1: invalid_file }
  end

  it 'sets an alert' do
    expect(assigns(:alert)).to eq('No commodities uploaded, please ensure valid commodity codes are in column A')
  end

  it 'renders the new template again' do
    expect(response).to render_template(:new)
  end
end
