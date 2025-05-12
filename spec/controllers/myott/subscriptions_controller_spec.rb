require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  let(:section) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter) do
    instance_double(
      Chapter,
      to_param: '01',
      short_code: '01',
      to_s: 'Live animals',
    )
  end

  before do
    allow(Rails.cache).to receive(:fetch).with('sections_chapters', expires_in: 1.hour)
      .and_return({ section => [chapter] })
  end

  describe 'GET #dashboard' do
    before { get :dashboard }

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:email)).to be_present }
    it { expect(session[:chapter_ids]).to be_nil }
    it { expect(flash[:error]).to be_nil }
  end

  describe 'GET #chapter_selection' do
    before do
      session[:chapter_ids] = %w[01]
      get :chapter_selection
    end

    it { is_expected.to respond_with(:success) }

    it 'assigns the selected chapters' do
      expect(assigns(:selected_chapters)).to eq([chapter])
    end
  end

  describe 'POST #check_your_answers' do
    context 'when chapters are selected' do
      before do
        post :check_your_answers, params: { chapter_ids: %w[01] }
      end

      it { expect(flash[:error]).to be_nil }

      it { is_expected.to respond_with(:success) }

      it 'assigns the selected chapters' do
        expect(assigns(:selected_chapters)).to eq([chapter])
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

  describe 'POST #remove_chapter_selection' do
    let(:chapter_id_to_remove) { '01' }

    before do
      session[:chapter_ids] = %w[01 02]
      post :remove_chapter_selection, params: { chapter_id: chapter_id_to_remove }
    end

    it 'removes the chapter ID from the session' do
      expect(session[:chapter_ids]).not_to include(chapter_id_to_remove)
    end

    it 'responds with 200 OK' do
      expect(response).to have_http_status(:ok)
    end
  end
end
