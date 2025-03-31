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
end

class MyFakeController < ApplicationController
  def bad_action
    raise URI::InvalidURIError
  end

  def bad_connection
    raise Faraday::ConnectionFailed
  end
end

RSpec.describe MyFakeController, type: :controller do
  before do
    routes.disable_clear_and_finalize = true
    routes.draw { get 'bad_action' => 'my_fake#bad_action' }
    routes.draw { get 'bad_connection' => 'my_fake#bad_connection' }
    routes.finalize!
  end

  describe 'invalid uri' do
    subject(:response) { get :bad_action }

    it { expect(response.status).to eq(404) }
  end

  describe 'bad backend connection' do
    subject(:response) { get :bad_connection }

    it { expect(response.status).to eq(500) }
  end
end
