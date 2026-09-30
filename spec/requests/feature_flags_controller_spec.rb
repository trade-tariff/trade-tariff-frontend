require 'spec_helper'

RSpec.describe FeatureFlagsController, type: :request do
  context 'when the management client is not configured' do
    before do
      FlagsmithManagementClient.instance = nil
    end

    after do
      FlagsmithManagementClient.instance = TEST_FLAGSMITH_MANAGEMENT_CLIENT
    end

    it 'returns 404 for GET /feature-flags' do
      get feature_flags_path
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for PATCH /feature-flags/:id' do
      patch feature_flag_path('interactive_search'), params: { enabled: 'true' }
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when the management client is configured' do
    describe 'GET /feature-flags' do
      subject(:perform_request) { get feature_flags_path }

      context 'when a registered optin feature is enabled' do
        before do
          enable_feature('interactive_search')
          perform_request
        end

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'shows the registered optin feature' do
          expect(response.body).to include('Interactive search')
        end

        it 'shows the enabled state' do
          expect(response.body).to include('Enabled')
        end
      end

      context 'when a registered optin feature is not yet enabled by the user' do
        before { perform_request }

        it 'shows the feature as disabled' do
          expect(response.body).to include('Disabled')
        end
      end
    end

    describe 'PATCH /feature-flags/:id' do
      it 'redirects back to the feature flags page' do
        patch feature_flag_path('interactive_search'), params: { enabled: 'true' }

        expect(response).to redirect_to(feature_flags_path)
      end

      it 'writes the trait to the management client' do
        patch feature_flag_path('interactive_search'), params: { enabled: 'true' }

        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to include(
          hash_including(trait_key: 'interactive_search', trait_value: true),
        )
      end

      it 'disables the trait when enabled is false' do
        patch feature_flag_path('interactive_search'), params: { enabled: 'false' }

        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to include(
          hash_including(trait_key: 'interactive_search', trait_value: false),
        )
      end

      it 'stores the enabled trait in the session' do
        patch feature_flag_path('interactive_search'), params: { enabled: 'true' }

        expect(session[:flagsmith_optin_traits]).to include('interactive_search' => true)
      end

      it 'stores the disabled trait in the session' do
        patch feature_flag_path('interactive_search'), params: { enabled: 'false' }

        expect(session[:flagsmith_optin_traits]).to include('interactive_search' => false)
      end

      it 'redirects when the flag is not a registered optin flag' do
        patch feature_flag_path('unknown_flag'), params: { enabled: 'true' }

        expect(response).to redirect_to(feature_flags_path)
      end

      it 'does not write a trait when the flag is not a registered optin flag' do
        patch feature_flag_path('unknown_flag'), params: { enabled: 'true' }

        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
      end
    end
  end
end
