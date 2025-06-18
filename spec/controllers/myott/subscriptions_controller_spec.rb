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

  describe 'GET #dashboard' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :dashboard
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :dashboard
      end

      context 'with user subscribed to all chapters' do
        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:amount_of_selected_chapters)).to eq('all')
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
          expect(assigns(:amount_of_selected_chapters)).to eq(2)
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
          expect(response).to redirect_to(myott_preference_selection_path)
        end
      end
    end
  end

  describe 'GET #chapter_selection' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :chapter_selection
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        session[:chapter_ids] = %w[01]
        get :chapter_selection
      end

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1])
      end
    end
  end

  describe 'POST #check_your_answers' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :check_your_answers, params: { chapter_ids: %w[01 03] }
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when some chapters are selected' do
        before do
          session[:chapter_ids] = %w[01 03]
          post :check_your_answers, params: { chapter_ids: %w[01 03] }
        end

        it { expect(flash.now[:error]).to be_nil }

        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:amount_of_selected_chapters)).to eq(2)
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section => [chapter1, chapter3],
          )
        end
      end

      context 'when no chapters are selected' do
        before do
          session[:chapter_ids] = %w[01]
          post :check_your_answers, params: {}
        end

        it 'renders the chapter_selection template again' do
          expect(response).to render_template(:chapter_selection)
        end

        it 'sets a flash error message' do
          expect(flash.now[:error]).to eq('Select the chapters you want tariff updates about.')
        end
      end
    end
  end

  describe 'GET #check_your_answers' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :check_your_answers, params: { all_tariff_updates: 'true' }
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        session[:chapter_ids] = %w[01]
        get :check_your_answers, params: { all_tariff_updates: 'true' }
      end

      context 'when all chapters are selected' do
        it { expect(flash.now[:error]).to be_nil }

        it { is_expected.to respond_with(:success) }

        it 'assigns the correct amount of selected chapters' do
          expect(assigns(:amount_of_selected_chapters)).to eq('all')
        end

        it 'assigns selected sections and chapters' do
          expect(assigns(:selected_sections_chapters)).to eq(
            section => [chapter1, chapter2, chapter3],
          )
        end
      end
    end
  end

  describe 'POST #set_preferences' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :set_preferences, params: { preference: 'selectChapters' }
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when selectChapters is selected' do
        before do
          post :set_preferences, params: { preference: 'selectChapters' }
        end

        it { is_expected.to redirect_to(myott_chapter_selection_path) }
      end

      context 'when allChapters is selected' do
        before do
          post :set_preferences, params: { preference: 'allChapters' }
        end

        it { is_expected.to redirect_to(myott_check_your_answers_path(all_tariff_updates: true)) }
      end

      context 'when no option is selected' do
        before do
          post :set_preferences, params: {}
        end

        it 'renders the chapter_selection template again' do
          expect(response).to render_template(:preference_selection)
        end

        it 'sets a flash error message' do
          expect(flash.now[:error]).to eq('Select a subscription preference to continue')
        end

        it 'sets a flash select_error message' do
          expect(flash.now[:select_error]).to eq('Select an option to continue')
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

        it { is_expected.to redirect_to(myott_subscription_confirmation_path) }

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

      context 'when all chapters are selected' do
        before do
          session[:all_tariff_updates] = true
          stub_api_request('/user/users', :put)
            .and_return(jsonapi_error_response(401))

          post :subscribe, params: { all_tariff_updates: 'true' }
        end

        it { is_expected.to redirect_to(myott_check_your_answers_path(all_tariff_updates: true)) }
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
