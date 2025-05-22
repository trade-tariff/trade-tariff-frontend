require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  let(:section) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter1) { instance_double(Chapter, to_param: '01', short_code: '01', to_s: 'Live animals') }
  let(:chapter2) { instance_double(Chapter, to_param: '02', short_code: '02', to_s: 'Meat') }

  before do
    allow(Rails.cache).to receive(:fetch).with('sections_chapters', expires_in: 1.day)
      .and_return({ section => [chapter1, chapter2] })
  end

  describe 'GET #dashboard' do
    let(:user) { build(:user) }

    before { get :dashboard }

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:email)).to be_present }
    it { expect(session[:chapter_ids]).to be_nil }

    context 'when current_user exists' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'assigns @email with current_user email' do
        get :dashboard
        expect(assigns(:email)).to eq(user.email)
      end
    end
  end

  describe 'GET #chapter_selection' do
    before do
      session[:chapter_ids] = %w[01]
      get :chapter_selection
    end

    it { is_expected.to respond_with(:success) }

    it 'assigns the selected chapters' do
      expect(assigns(:selected_chapters)).to eq([chapter1])
    end
  end

  describe 'POST #check_your_answers' do
    context 'when chapters are selected' do
      before do
        post :check_your_answers, params: { chapter_ids: %w[01] }
      end

      it { expect(flash.now[:error]).to be_nil }

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1])
      end

      it 'stores the selection in the session' do
        expect(session[:chapter_ids]).to eq(%w[01])
      end
    end

    context 'when no chapters are selected' do
      before do
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
        get :check_your_answers, params: { all_tariff_updates: 'true' }
      end

      it { expect(flash.now[:error]).to be_nil }

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter1, chapter2])
      end

      it 'stores the selection in the session' do
        expect(session[:chapter_ids]).to eq(%w[01 02])
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
        expect(flash.now[:error]).to eq('Please select an option.')
      end
    end
  end
end
