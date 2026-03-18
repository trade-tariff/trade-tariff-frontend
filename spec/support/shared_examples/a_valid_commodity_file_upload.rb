RSpec.shared_examples 'a valid commodity file upload' do |fixture_path, content_type|
  let(:valid_file) { fixture_file_upload(fixture_path, content_type) }
  let(:token) { 'valid-jwt-token' }

  context 'when the user has an existing subscription' do
    before do
      cookies[:id_token] = token

      allow(Subscription).to receive(:batch)
      allow(controller).to receive(:get_subscription).and_return(subscription)

      post :create, params: { myott_commodity_upload_form: { file: valid_file } }
    end

    it 'does not set an alert' do
      expect(assigns(:alert)).to be_nil
    end

    it 'calls Subscription.batch with parsed commodity codes' do
      expect(Subscription).to have_received(:batch).with(
        subscription.resource_id,
        token,
        hash_including(
          targets: kind_of(Array),
        ),
      )
    end

    it 'redirects to the index page' do
      expect(response).to redirect_to(confirmation_myott_mycommodities_path(params: { new_subscriber: false }))
    end
  end

  context 'when the user does not have an existing subscription' do
    before do
      cookies[:id_token] = token

      allow(Subscription).to receive(:batch)

      allow(controller).to receive(:current_subscription)
                       .with('my_commodities')
                       .and_return(nil, subscription)

      allow(User).to receive(:update).and_return(true)

      post :create, params: { myott_commodity_upload_form: { file: valid_file } }
    end

    it 'does not set an alert' do
      expect(assigns(:alert)).to be_nil
    end

    it 'calls User.update with my_commodities_subscription set to true' do
      expect(User).to have_received(:update).with(token, my_commodities_subscription: 'true')
    end

    it 'calls Subscription.batch with parsed commodity codes' do
      expect(Subscription).to have_received(:batch).with(
        subscription.resource_id,
        token,
        hash_including(
          targets: kind_of(Array),
        ),
      )
    end

    it 'redirects to the index page' do
      expect(response).to redirect_to(confirmation_myott_mycommodities_path(params: { new_subscriber: true }))
    end
  end

  context 'when user subscription update succeeds but subscription is still missing' do
    before do
      cookies[:id_token] = token

      allow(User).to receive(:update).and_return(true)
      allow(Subscription).to receive(:batch)

      allow(controller).to receive(:current_subscription)
        .with('my_commodities')
        .and_return(nil, nil)

      post :create, params: { myott_commodity_upload_form: { file: valid_file } }
    end

    it 'does not call Subscription.batch' do
      expect(Subscription).not_to have_received(:batch)
    end

    it 'sets the error' do
      expect(assigns(:upload_form).errors[:file]).to include('We could not create your subscription. Please try again.')
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end
end
