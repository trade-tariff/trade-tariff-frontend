require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  let(:policy_cookie) do
    {
      settings: true,
      usage: 'true',
      remember_settings: 'true',
    }.to_json
  end

  it 'has the correct Cache-Control header' do
    get :index
    expect(response.headers['Cache-Control']).to eq('no-cache')
  end

  context 'when cookies are set' do
    before do
      request.cookies['cookies_policy'] = policy_cookie
      request.cookies['cookies_preferences_set'] = true
      get :index
    end

    let(:expected_cache_control) do
      'max-age=7200, public, stale-if-error=86400, stale-while-revalidate=86400'
    end

    it 'has the correct Cache-Control header' do
      expect(response.headers['Cache-Control']).to eq(expected_cache_control)
    end
  end
end
