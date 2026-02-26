RSpec.describe Myott::PreferencesController, type: :controller do
  include MyottAuthenticationHelpers
  include_context 'with cached chapters'

  let(:user) { build(:user, chapter_ids: '') }

  describe 'GET #new' do
    it_behaves_like 'a protected myott page', :new

    context 'when current_user is valid' do
      before do
        session[:chapter_ids] = %w[01 02]
        session[:all_tariff_updates] = true
        stub_authenticated_user(user)
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
        stub_unauthenticated_user
        post :create, params: { preference: 'selectChapters' }
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
      end

      context 'when selectChapters is selected' do
        before do
          post :create, params: { myott_stop_press_preference_form: { preference: 'selectChapters' } }
        end

        it { is_expected.to redirect_to(edit_myott_stop_press_preferences_path) }
      end

      context 'when allChapters is selected' do
        before do
          post :create, params: { myott_stop_press_preference_form: { preference: 'allChapters' } }
        end

        it { is_expected.to redirect_to(check_your_answers_myott_stop_press_path) }
      end

      context 'when no option is selected' do
        before do
          post :create, params: {}
        end

        it 'renders the chapter_selection template again' do
          expect(response).to render_template(:new)
        end

        it 'displays validation errors' do
          expect(assigns(:form).errors[:preference]).to be_present
        end
      end
    end
  end

  describe 'GET #edit' do
    it_behaves_like 'a protected myott page', :edit

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
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
