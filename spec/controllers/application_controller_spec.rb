require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  it 'has the correct Cache-Control header' do
    get :index
    expect(response.headers['Cache-Control']).to eq('no-cache')
  end
end
