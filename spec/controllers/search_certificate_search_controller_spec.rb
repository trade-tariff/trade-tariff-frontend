require 'spec_helper'

RSpec.describe SearchController, 'GET to #certificate_search', type: :controller,
  slow: true, vcr: { cassette_name: 'search#certificate_search' } do

  context 'without search params' do
    render_views

    before do
      get :certificate_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Certificate search results/)
    end
  end

  context 'search by code' do
    render_views

    before do
      get :certificate_search, params: { code: '119' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Certificate search results/)
    end
  end

  context 'search by type' do
    render_views

    before do
      get :certificate_search, params: { type: 'A' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Certificate search results/)
    end
  end

  context 'search by description' do
    render_views

    before do
      get :certificate_search, params: { description: 'import licence' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Certificate search results/)
    end
  end
end
