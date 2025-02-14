require 'spec_helper'

RSpec.describe Chapters::ChangesController, type: :controller do
  describe 'GET index' do
    context 'when chapter is valid at given date', vcr: { cassette_name: 'chapters_changes#index' } do
      before do
        get :index, params: { chapter_id: '01' }, format: :atom
      end

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:changeable)).to be_present }
      it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
    end
  end
end
