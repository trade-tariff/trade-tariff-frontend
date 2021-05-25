require 'spec_helper'

describe SearchController, 'GET to #chemical_search', type: :controller, vcr: { cassette_name: 'search#chemical_search' } do
  before do
    Rails.cache.clear
  end

  context 'without search params' do
    render_views

    before do
      get :chemical_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Chemical search results/)
    end
  end

  context 'search by CAS number' do
    render_views

    before do
      get :chemical_search, params: { cas: '121-17-5' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Chemical search results/)
      expect(response.body).to match(/121-17-5/)
    end
  end

  context 'search by (partial) chemical name' do
    render_views

    before do
      get :chemical_search, params: { name: 'isopropyl' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Chemical search results/)
      expect(response.body).to match(/isopropyl/)
    end
  end
end
