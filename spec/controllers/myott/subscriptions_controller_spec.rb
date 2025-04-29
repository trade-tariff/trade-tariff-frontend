require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  describe 'GET dashboard' do
    before do
      get :dashboard
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:email)).to be_present }
  end
end
