require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  let(:section) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter1) { instance_double(Chapter, to_param: '01', short_code: '01', to_s: 'Live animals') }
  let(:chapter2) { instance_double(Chapter, to_param: '02', short_code: '02', to_s: 'Meat') }
  let(:chapter3) { instance_double(Chapter, to_param: '03', short_code: '03', to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates') }
  let(:user) { build(:user, chapter_ids: '', stop_press_subscription: true) }

  before do
    allow(Rails.cache).to receive(:fetch).with('all_sections_chapters', expires_in: 1.day)
      .and_return({ section => [chapter1, chapter2, chapter3] })
  end

  describe 'GET #start' do
    it 'does not authenticate the user' do
      allow(controller).to receive(:authenticate)

      get :start
      expect(controller).not_to have_received(:authenticate)
    end
  end

  describe 'GET #invalid' do
    it 'does not authenticate the user' do
      allow(controller).to receive(:authenticate)

      get :invalid
      expect(controller).not_to have_received(:authenticate)
    end

    context 'when a user does exist' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :invalid
      end

      it { is_expected.to redirect_to myott_path }
    end

    context 'when a user does not exist' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :invalid
      end

      it { is_expected.not_to redirect_to myott_path }
    end
  end

  describe 'GET #show' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :show
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :show
      end

      context 'with user subscribed to all chapters' do
        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:selected_chapters_heading)).to eq('You have selected all chapters')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section => [chapter1, chapter2, chapter3],
          )
        end
      end

      context 'with subscribed user to some chapters' do
        let(:user) { build(:user, stop_press_subscription: true, chapter_ids: '01,03') }

        before do
          session[:chapter_ids] = %w[01,03]
        end

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:selected_chapters_heading)).to eq('You have selected 2 chapters')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section => [chapter1, chapter3],
          )
        end
      end

      context 'with unsubscribed user' do
        let(:user) { build(:user, stop_press_subscription: false) }

        it 'redirects to sign up page' do
          expect(response).to redirect_to(new_myott_preferences_path)
        end
      end
    end
  end

  describe 'GET #check_your_answers' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        session[:all_tariff_updates] = true
        get :check_your_answers
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
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
            section => [chapter1, chapter2, chapter3],
          )
        end
      end
    end
  end

  describe 'POST #subscribe' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :subscribe
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      let(:attributes) { { chapter_ids: '01,03', stop_press_subscription: 'true' } }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        token = 'valid-jwt-token'
        cookies[:id_token] = token
        session[:chapter_ids] = %w[01 03]
      end

      context 'when the update is successful' do
        before do
          stub_api_request('/user/users', :put)
            .with(body: {
              data: {
                attributes: attributes,
              },
            })
            .and_return(jsonapi_response(:user, attributes))

          post :subscribe
        end

        it { is_expected.to respond_with(:redirect) }

        it { is_expected.to redirect_to(myott_confirmation_path) }

        it 'clears the session chapter ids' do
          expect(session[:chapter_ids]).to be_nil
        end

        it 'clears the session all_tariff_updates flag' do
          expect(session[:all_tariff_updates]).to be_nil
        end
      end

      context 'when the update fails' do
        before do
          stub_api_request('/user/users', :put)
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
          expect(flash[:error]).to eq('There was an error updating your subscription. Please try again.')
        end
      end
    end
  end

  describe 'GET #confirmation' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :confirmation
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :confirmation
      end

      it { is_expected.to respond_with(:success) }

      context 'when user is not subscribed' do
        let(:user) { build(:user, stop_press_subscription: false) }

        it 'redirects' do
          expect(response).to redirect_to(myott_path)
        end
      end
    end
  end

  describe 'GET #preference_selection' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :dashboard
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    it 'clears the session chapter ids' do
      expect(session[:chapter_ids]).to be_nil
    end
  end
end
