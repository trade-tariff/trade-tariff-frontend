require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  describe 'GET #index' do
    subject { response.headers.to_h }

    before { get :index }

    it { is_expected.to include 'Cache-Control' => 'no-store' }
  end
end
