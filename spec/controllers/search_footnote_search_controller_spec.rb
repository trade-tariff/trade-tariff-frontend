require 'spec_helper'

RSpec.describe SearchController, 'GET to #footnote_search', type: :controller do
  before do
    Rails.cache.clear
  end

  context 'without search params', vcr: { cassette_name: 'search#footnote_search_without_params' } do
    render_views

    before do
      get :footnote_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Footnote search results/)
    end
  end

  context 'search by code', vcr: { cassette_name: 'search#footnote_search_by_code' } do
    render_views

    before do
      get :footnote_search, params: { code: '133' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Footnote search results/)
    end
  end

  context 'search by type', vcr: { cassette_name: 'search#footnote_search_by_type' } do
    render_views

    before do
      get :footnote_search, params: { type: 'TN' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Footnote search results/)
    end
  end

  context 'search by description', vcr: { cassette_name: 'search#footnote_search_by_description' } do
    render_views

    before do
      get :footnote_search, params: { description: 'copper' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Footnote search results/)
    end
  end
end
