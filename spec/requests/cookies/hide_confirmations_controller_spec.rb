require 'spec_helper'

RSpec.describe Cookies::HideConfirmationsController, type: :request do
  describe 'POST #create' do
    before { post cookies_hide_confirmation_path }

    it 'sets the cookie preference correctly' do
      expect(response.cookies['cookies_preferences_set']).to eq('true')
    end

    it 'redirects to the correct fallback location' do
      expect(response).to redirect_to(sections_path)
    end
  end
end
