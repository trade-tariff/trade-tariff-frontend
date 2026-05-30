require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  describe 'GET #index' do
    subject(:response) { get :index }

    let(:expected_cache_control) do
      %w[
        max-age=0
        public
        must-revalidate
        proxy-revalidate
      ].join(', ')
    end

    it { expect(response.headers['Cache-Control']).to eq(expected_cache_control) }
    it { expect(response.headers['Pragma']).to eq('no-cache') }
    it { expect(response.headers['Expires']).to eq('-1') }
  end

  describe '#current_flipper_actor' do
    context 'when no JWT cookie is present' do
      it 'returns an AnonymousActor' do
        get :index
        expect(controller.send(:current_flipper_actor)).to be_a(Flipper::AnonymousActor)
      end

      it 'sets the flipper_anonymous_id cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_present
      end

      it 'uses the same UUID on subsequent requests' do
        get :index
        first_uuid = cookies[:flipper_anonymous_id]
        get :index
        expect(cookies[:flipper_anonymous_id]).to eq(first_uuid)
      end
    end
  end

  describe '#current_flipper_actor (authenticated)' do
    let(:payload) { { 'email' => 'user@example.com' } }
    let(:token)   { JWT.encode(payload, nil, 'none') }

    before { cookies[TradeTariffFrontend.id_token_cookie_name] = token }

    it 'returns a UserActor' do
      get :index
      expect(controller.send(:current_flipper_actor)).to be_a(Flipper::UserActor)
    end

    it 'uses the email as the actor user_id' do
      get :index
      expect(controller.send(:current_flipper_actor).flipper_id).to eq('User:user@example.com')
    end

    context 'when the JWT payload has no email or sub' do
      let(:payload) { { 'iat' => Time.zone.now.to_i } }

      it 'falls back to an AnonymousActor' do
        get :index
        expect(controller.send(:current_flipper_actor)).to be_a(Flipper::AnonymousActor)
      end
    end

    context 'when the JWT is malformed' do
      before { cookies[TradeTariffFrontend.id_token_cookie_name] = 'not.a.jwt' }

      it 'falls back to an AnonymousActor' do
        get :index
        expect(controller.send(:current_flipper_actor)).to be_a(Flipper::AnonymousActor)
      end
    end
  end

  describe 'Current.flipper_actor' do
    it 'is set before action runs' do
      captured_actor = nil
      allow(controller).to receive(:index).and_wrap_original do |original|
        captured_actor = Current.flipper_actor
        original.call
      end
      get :index
      expect(captured_actor).to be_a(Flipper::AnonymousActor)
    end
  end

  describe '#migrate_anonymous_flipper_actor' do
    let(:anonymous_uuid) { 'anon-uuid-999' }
    let(:user_id)        { 'user@example.com' }
    let(:anonymous_actor) { Flipper::AnonymousActor.new(anonymous_uuid) }
    let(:user_actor)      { Flipper::UserActor.new(user_id) }

    before do
      cookies[:flipper_anonymous_id] = anonymous_uuid
      allow(controller).to receive(:current_user_id).and_return(user_id)
    end

    context 'when the anonymous actor has opted into a feature' do
      before { Flipper.enable_actor(:some_feature, anonymous_actor) }

      it 'enables the feature for the user actor' do
        get :index
        expect(Flipper.enabled?(:some_feature, user_actor)).to be true
      end

      it 'clears the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_blank
      end
    end

    context 'when the anonymous actor has no opt-ins' do
      it 'clears the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_blank
      end
    end

    context 'when current_user_id is nil (anonymous request)' do
      before { allow(controller).to receive(:current_user_id).and_return(nil) }

      it 'does not clear the anonymous cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to eq(anonymous_uuid)
      end
    end
  end
end
