RSpec.describe Myott::StopPressesController, type: :controller do
  include MyottAuthenticationHelpers

  include_context 'with cached chapters'

  let(:user) { build(:user, chapter_ids: '') }

  describe 'GET #show' do
    it_behaves_like 'a protected myott page', :show

    context 'when user does not have a subscription' do
      before do
        stub_authenticated_user
        stub_current_subscription('stop_press', nil)
        get :show
      end

      it 'redirects to new preferences path' do
        expect(response).to redirect_to(new_myott_stop_press_preferences_path)
      end
    end

    context 'when current_user is valid' do
      let(:subscription) { build(:subscription, subscription_type: 'stop_press') }

      before do
        stub_authenticated_user(user)
        stub_current_subscription('stop_press', subscription)
      end

      context 'with user subscribed to all chapters' do
        before { get :show }

        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:selected_chapters_heading)).to eq('You have selected all chapters')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section1 => [chapter1, chapter2], section2 => [chapter3],
          )
        end
      end

      context 'with subscribed user to some chapters' do
        let(:user) { build(:user, chapter_ids: '01,03') }

        before do
          session[:chapter_ids] = %w[01 03]
          get :show
        end

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:selected_chapters_heading)).to eq('You have selected 2 chapters')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section1 => [chapter1], section2 => [chapter3],
          )
        end
      end

      context 'with unsubscribed user' do
        let(:user) { build(:user) }

        before do
          stub_current_subscription('stop_press', nil)
          get :show
        end

        it 'redirects to sign up page' do
          expect(response).to redirect_to(new_myott_stop_press_preferences_path)
        end
      end
    end
  end

  describe 'GET #check_your_answers' do
    context 'when current_user is not valid' do
      before do
        stub_unauthenticated_user_with_bypass
        session[:all_tariff_updates] = true
        get :check_your_answers
      end

      it { is_expected.to respond_with(:success) }
    end

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
        session[:chapter_ids] = %w[01 02 03]
        session[:all_tariff_updates] = true
        get :check_your_answers
      end

      context 'when all chapters are selected' do
        it { expect(flash.now[:error]).to be_nil }

        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:selected_chapters_heading)).to eq('You have selected all chapters')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section1 => [chapter1, chapter2], section2 => [chapter3],
          )
        end
      end
    end
  end

  describe 'POST #subscribe' do
    context 'when current_user is not valid' do
      before do
        stub_unauthenticated_user
        session[:chapter_ids] = %w[01 03]
        post :subscribe
      end

      it 'handles nil session gracefully' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when current_user is valid' do
      let(:attributes) { { chapter_ids: '01,03', stop_press_subscription: 'true' } }

      before do
        stub_authenticated_user(user)
        token = 'valid-jwt-token'
        cookies[:id_token] = token
        session[:chapter_ids] = %w[01 03]
      end

      context 'when the update is successful' do
        before do
          stub_api_request('http://localhost:3018/uk/user/users', :put)
            .with(body: {
              data: {
                attributes: attributes,
              },
            })
            .and_return(jsonapi_response(:user, attributes))

          post :subscribe
        end

        it { is_expected.to respond_with(:redirect) }

        it { is_expected.to redirect_to(confirmation_myott_stop_press_path) }

        it 'clears the session chapter ids' do
          expect(session[:chapter_ids]).to be_nil
        end

        it 'clears the session all_tariff_updates flag' do
          expect(session[:all_tariff_updates]).to be_nil
        end
      end

      context 'when the update fails' do
        before do
          stub_api_request('http://localhost:3018/uk/user/users', :put)
            .and_return(jsonapi_error_response(401))

          post :subscribe
        end

        it 'does not render confirmation' do
          expect(response).not_to render_template(:subscription_confirmation)
        end

        it 'does not clear the session chapter ids' do
          expect(session[:chapter_ids]).to eq(%w[01 03])
        end

        it 'sets a flash error message' do
          expect(flash[:alert]).to eq('There was an error updating your subscription. Please try again.')
        end
      end
    end
  end

  describe 'GET #confirmation' do
    it_behaves_like 'a protected myott page', :confirmation

    context 'when current_user is valid' do
      let(:subscription) { build(:subscription, subscription_type: 'stop_press') }

      before do
        stub_authenticated_user(user)
        stub_current_subscription('stop_press', subscription)
        get :confirmation
      end

      it { is_expected.to respond_with(:success) }

      context 'when user is not subscribed' do
        let(:user) { build(:user) }

        before do
          stub_current_subscription('stop_press', nil)
          get :confirmation
        end

        it 'redirects' do
          expect(response).to redirect_to(myott_path)
        end
      end
    end
  end
end
