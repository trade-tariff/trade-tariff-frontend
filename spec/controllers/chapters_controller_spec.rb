require 'spec_helper'

RSpec.describe ChaptersController, type: :controller, vcr: { cassette_name: 'chapters#show' } do
  describe 'GET #show' do
    let!(:chapter) { build :chapter, section: attributes_for(:section) }

    before do
      get :show, params: { id: chapter.to_param }
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:chapter)).to be_a(Chapter) }
    it { expect(assigns(:headings)).to be_a(Array) }
    it { expect(session[:goods_nomenclature_code]).to eq('01') }
  end
end
