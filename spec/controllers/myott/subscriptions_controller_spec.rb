require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  let(:section) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter1) { instance_double(Chapter, to_param: '01', short_code: '01', to_s: 'Live animals') }
  let(:chapter2) { instance_double(Chapter, to_param: '02', short_code: '02', to_s: 'Meat') }
  let(:chapter3) { instance_double(Chapter, to_param: '03', short_code: '03', to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates') }

  before do
    allow(Rails.cache).to receive(:fetch).with('sections_chapters', expires_in: 1.day)
      .and_return({ section => [chapter1, chapter2, chapter3] })
  end

  describe 'GET #dashboard' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :dashboard
    end

    context 'with user subscribed to all chapters' do
      let(:user) { build(:user, chapter_ids: '', stop_press_subscription: true) }

      it { is_expected.to respond_with(:success) }

      it 'assigns @email with current_user email' do
        expect(assigns(:email)).to eq(user.email)
      end

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1, chapter2, chapter3])
      end
    end

    context 'with subscribed user to some chapters' do
      let(:user) { build(:user, stop_press_subscription: true, chapter_ids: '01,03') }

      before do
        session[:chapter_ids] = %w[01,03]
      end

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1, chapter3])
      end
    end

    context 'with unsubscribed user' do
      let(:user) { build(:user, stop_press_subscription: false) }

      it 'redirects to sign up page' do
        expect(response).to redirect_to(myott_preference_selection_path)
      end
    end
  end

  # need to add test for 'subscribe' action

  describe 'GET #chapter_selection' do
    before do
      session[:subscription_in_progress] = true
      session[:chapter_ids] = %w[01]
      get :chapter_selection
    end

    it { is_expected.to respond_with(:success) }

    it 'assigns the selected chapters' do
      expect(assigns(:selected_chapters)).to eq([chapter1])
    end
  end

  describe 'POST #check_your_answers' do
    context 'when some chapters are selected' do
      before do
        session[:subscription_in_progress] = true
        post :check_your_answers, params: { chapter_ids: %w[01 03] }
      end

      it { expect(flash.now[:error]).to be_nil }

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1, chapter3])
      end
    end

    context 'when no chapters are selected' do
      before do
        session[:subscription_in_progress] = true
        post :check_your_answers, params: { chapter_ids: [] }
      end

      it 'renders the chapter_selection template again' do
        expect(response).to render_template(:chapter_selection)
      end

      it 'sets a flash error message' do
        expect(flash.now[:error]).to eq('Select the chapters you want tariff updates about.')
      end
    end
  end

  describe 'GET #check_your_answers' do
    context 'when all chapters are selected' do
      before do
        session[:subscription_in_progress] = true
        get :check_your_answers, params: { all_tariff_updates: 'true' }
      end

      it { expect(flash.now[:error]).to be_nil }

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1, chapter2, chapter3])
      end
    end
  end

  describe 'POST #set_preferences' do
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

  describe 'POST #subscribe' do
    let(:attributes) { { chapter_ids: '01,03', stop_press_subscription: 'true' } }

    before do
      token = 'valid-jwt-token'
      cookies[:id_token] = token
      session[:chapter_ids] = %w[01 03]
      session[:subscription_in_progress] = true
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

      it { is_expected.to respond_with(:success) }

      it 'renders the confirmation template' do
        expect(response).to render_template(:subscription_confirmation)
      end

      it 'clears the session' do
        expect(session[:chapter_ids]).to be_nil
        expect(session[:all_tariff_updates]).to be_nil
        expect(session[:subscription_in_progress]).to be false
      end
    end

    context 'when the update fails' do
      before do
        stub_api_request('/user/users', :put)
          .and_return(jsonapi_error_response(401)) # or nil if update returns nil

        post :subscribe
      end

      it 'does not render confirmation' do
        expect(response).not_to render_template(:subscription_confirmation)
      end

      it 'does not clear the session' do
        expect(session[:chapter_ids]).to eq(%w[01 03])
        expect(session[:subscription_in_progress]).to be true
      end
    end
  end
end
