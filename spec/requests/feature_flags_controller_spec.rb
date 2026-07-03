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

      context 'when optin flags are enabled' do
        before do
          enable_feature('interactive_search_optin')
          enable_feature('interactive_search')
          perform_request
        end

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'shows the available opt-in feature' do
          expect(response.body).to include('Interactive search')
        end

        it 'shows the enabled state' do
          expect(response.body).to include('Enabled')
        end
      end

      context 'when no optin flags are enabled' do
        before { perform_request }

        it 'shows the empty state message' do
          expect(response.body).to include('No features are currently available for opt-in')
        end
      end

      context 'when a feature is available but disabled' do
        before do
          enable_feature('interactive_search_optin')
          perform_request
        end

        it 'shows the feature as disabled' do
          expect(response.body).to include('Disabled')
        end
      end
    end

    describe 'PATCH /feature-flags/:id' do
      before { enable_feature('interactive_search_optin') }

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

      it 'redirects when the flag is not in the optin allowlist' do
        patch feature_flag_path('unknown_flag'), params: { enabled: 'true' }

        expect(response).to redirect_to(feature_flags_path)
      end

      it 'does not write a trait when the flag is not in the optin allowlist' do
        patch feature_flag_path('unknown_flag'), params: { enabled: 'true' }

        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
      end
    end
  end
end
