require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  before do
    get :index
    cookies['cookies_policy'] = policy_cookie
    cookies['cookies_preferences_set'] = true
  end

  let(:policy_cookie) do
    {
      settings: true,
      usage: 'true',
      remember_settings: 'true',
    }.to_json
  end

  let(:expected_cache_control) do
    'max-age=7200, public, stale-if-error=86400, stale-while-revalidate=86400'
  end

#   it 'has the correct Cache-Control header' do
#     expect(response.headers['Cache-Control']).to eq(expected_cache_control)
#   end
end
