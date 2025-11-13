RSpec.shared_examples 'a valid commodity file upload' do |fixture_path, content_type|
  let(:valid_file) { fixture_file_upload(fixture_path, content_type) }

  before do
    token = 'valid-jwt-token'
    cookies[:id_token] = token

    allow(Subscription).to receive(:batch)
    allow(controller).to receive(:get_subscription).and_return(subscription)

    post :create, params: { fileUpload1: valid_file }
  end

  it 'does not set an alert' do
    expect(assigns(:alert)).to be_nil
  end

  it 'calls Subscription.batch with parsed commodity codes' do
    expect(Subscription).to have_received(:batch).with(
      subscription.resource_id,
      hash_including(
        targets: kind_of(Array),
        subscription_type: 'my_commodities',
      ),
    )
  end

  it 'redirects to the index page' do
    expect(response).to redirect_to(myott_mycommodities_path)
  end
end
