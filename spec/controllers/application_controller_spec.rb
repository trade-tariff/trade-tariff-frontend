require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
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
end
