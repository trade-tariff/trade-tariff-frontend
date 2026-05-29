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
end
