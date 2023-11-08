require 'spec_helper'

RSpec.describe Chapters::ChangesController, type: :controller do
  let!(:chapter) { Chapter.new(attributes_for(:chapter, goods_nomenclature_item_id: '0100000000')) }

  describe 'GET index' do
    context 'when chapter is valid at given date', vcr: { cassette_name: 'chapters_changes#index' } do
      before do
        get :index, params: { chapter_id: chapter.short_code }, format: :atom
      end

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:changeable)).to be_present }
      it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
    end

    context 'when chapter has no changes at given date', vcr: { cassette_name: 'chapters_changes#index_0100000000_1972-01-01' } do
      before do
        get :index, params: { chapter_id: chapter.short_code, as_of: Date.new(1972, 1, 1) }, format: :atom
      end

      it { is_expected.to respond_with(:success) }
      it { expect(assigns(:changeable)).to be_present }
      it { expect(assigns(:changes)).to be_a(ChangesPresenter) }

      it 'fetches no changes' do
        expect(assigns[:changes]).to be_empty
      end
    end

    context 'when chapter is not valid at given date', vcr: { cassette_name: 'chapters_changes#index_0100000000_1970-01-01' } do
      let :request_page do
        get :index, params: { chapter_id: chapter.short_code, as_of: Date.new(1970, 1, 1) }, format: :atom
      end

      it { expect { request_page }.to raise_exception Faraday::ResourceNotFound }
    end
  end
end
