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

    describe 'the enhanced loading opt-in' do
      it 'lists the enhanced loading feature' do
        get feature_flags_path
        expect(response.body).to include('Enhanced guided search loading')
      end

      it 'persists and clears the loading preference', :aggregate_failures do
        patch feature_flag_path('enhanced_guided_search_loading'), params: { enabled: 'true' }
        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to include(
          hash_including(trait_key: 'enhanced_guided_search_loading', trait_value: true),
        )
        follow_redirect!
        expect(Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Enhanced guided search loading'))
          .to have_css('.govuk-tag', text: 'Enabled')

        patch feature_flag_path('enhanced_guided_search_loading'), params: { enabled: 'false' }
        follow_redirect!
        expect(Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Enhanced guided search loading'))
          .to have_css('.govuk-tag', text: 'Disabled')
      end
    end

    describe 'the parcel journey opt-in' do
      it 'lists the parcel journey' do
        get feature_flags_path
        expect(response.body).to include('Parcel gift journey')
      end

      it 'persists and clears the review trait', :aggregate_failures do
        patch feature_flag_path('parcel_gift_journey'), params: { enabled: 'true' }
        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to include(
          hash_including(trait_key: 'parcel_gift_journey', trait_value: true),
        )
        follow_redirect!
        expect(Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Parcel gift journey'))
          .to have_css('.govuk-tag', text: 'Enabled')

        patch feature_flag_path('parcel_gift_journey'), params: { enabled: 'false' }
        expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to include(
          hash_including(trait_key: 'parcel_gift_journey', trait_value: false),
        )
        follow_redirect!
        expect(Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Parcel gift journey'))
          .to have_css('.govuk-tag', text: 'Disabled')
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

      it 'enables a feature outside rollout', :aggregate_failures do
        disable_feature(:interactive_search)
        get feature_flags_path
        row = Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Interactive search')
        expect(row).to have_css('.govuk-tag', text: 'Disabled')
        expect(row).to have_button('Enable')

        form = row.find('form')
        patch form[:action], params: { enabled: form.find('input[name="enabled"]', visible: :hidden)[:value] }
        follow_redirect!

        row = Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Interactive search')
        expect(row).to have_css('.govuk-tag', text: 'Enabled')
        expect(row).to have_button('Disable')
        expect(session[:flagsmith_optin_traits]).to be_nil
      end

      it 'opts out of an automatic rollout', :aggregate_failures do
        enable_feature(:interactive_search)
        get feature_flags_path
        row = Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Interactive search')
        expect(row).to have_css('.govuk-tag', text: 'Enabled')
        expect(row).to have_button('Disable')

        form = row.find('form')
        patch form[:action], params: { enabled: form.find('input[name="enabled"]', visible: :hidden)[:value] }
        follow_redirect!

        row = Capybara.string(response.body).find('.govuk-summary-list__row', text: 'Interactive search')
        expect(row).to have_css('.govuk-tag', text: 'Disabled')
        expect(row).to have_button('Enable')
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
