require 'spec_helper'

RSpec.describe SearchController, 'GET to #additional_code_search', type: :controller, vcr: { cassette_name: 'search#additional_code_search' } do
  before do
    Rails.cache.clear
  end

  context 'without search params' do
    render_views

    before do
      get :additional_code_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Additional code search results/)
    end
  end

  context 'search by code' do
    render_views

    before do
      get :additional_code_search, params: { code: '119' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Additional code search results/)
    end
  end

  context 'search by type' do
    render_views

    before do
      get :additional_code_search, params: { type: '4' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Additional code search results/)
    end
  end

  context 'search by description' do
    render_views

    before do
      get :additional_code_search, params: { description: 'shanghai' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Additional code search results/)
    end
  end
end
