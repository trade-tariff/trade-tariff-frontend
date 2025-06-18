require 'spec_helper'

RSpec.describe Myott::PreferencesController, type: :controller do
  let(:section) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter1) { instance_double(Chapter, to_param: '01', short_code: '01', to_s: 'Live animals') }
  let(:chapter2) { instance_double(Chapter, to_param: '02', short_code: '02', to_s: 'Meat') }
  let(:chapter3) { instance_double(Chapter, to_param: '03', short_code: '03', to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates') }
  let(:user) { build(:user, chapter_ids: '', stop_press_subscription: false) }

  before do
    allow(Rails.cache).to receive(:fetch).with('all_sections_chapters', expires_in: 1.day)
      .and_return({ section => [chapter1, chapter2, chapter3] })
  end

  describe 'GET #new' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :new
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        session[:chapter_ids] = %w[01 02]
        session[:all_tariff_updates] = true
        allow(controller).to receive(:current_user).and_return(user)
        get :new
      end

      it { is_expected.to respond_with(:success) }

      it 'deletes chapter_ids from the session' do
        expect(session[:chapter_ids]).to be_nil
      end

      it 'deletes all_tariff_updates from the session' do
        expect(session[:all_tariff_updates]).to be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :create, params: { preference: 'selectChapters' }
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when selectChapters is selected' do
        before do
          post :create, params: { preference: 'selectChapters' }
        end

        it { is_expected.to redirect_to(edit_myott_preferences_path) }
      end

      context 'when allChapters is selected' do
        before do
          post :create, params: { preference: 'allChapters' }
        end

        it { is_expected.to redirect_to(myott_check_your_answers_path) }
      end

      context 'when no option is selected' do
        before do
          post :create, params: {}
        end

        it 'renders the chapter_selection template again' do
          expect(response).to render_template(:new)
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

  describe 'GET #edit' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :edit
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        session[:chapter_ids] = %w[01]
        get :edit
      end

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1])
      end
    end
  end
end
