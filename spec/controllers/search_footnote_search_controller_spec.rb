require 'spec_helper'

RSpec.describe SearchController, type: :controller, vcr: { cassette_name: 'search#footnote_search', record: :new_episodes } do
  render_views

  context 'without search params' do
    before do
      get :footnote_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Footnote search results/)
    end
  end

  context 'when searching by code and type' do
    before do
      get :footnote_search, params: { code: '133', type: 'TN' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Footnote search results/)
    end
  end

  context 'when searching by description' do
    before do
      get :footnote_search, params: { description: 'copper' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Footnote search results/)
    end
  end
end
