require 'spec_helper'

describe SearchController, 'GET to #quota_search', type: :controller, vcr: { cassette_name: 'search#quota_search', allow_playback_repeats: true } do
  before do
    Rails.cache.clear
  end

  context 'with xi as the service choice' do
    before do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(true)

      get :quota_search, params: { goods_nomenclature_item_id: '0301919011' }, format: :html
    end

    it { is_expected.to respond_with(:not_found) }
  end

  context 'without search params' do
    render_views

    before do
      get :quota_search, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays no results' do
      expect(response.body).not_to match(/Quota search results/)
    end
  end

  context 'search by goods nomenclature' do
    render_views

    before do
      get :quota_search, params: { goods_nomenclature_item_id: '0301919011' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Quota search results/)
    end
  end

  context 'search by origin' do
    render_views

    before do
      get :quota_search, params: { geographical_area_id: '1011' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Quota search results/)
    end
  end

  context 'search by order number' do
    render_views

    before do
      get :quota_search, params: { order_number: '090671' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Quota search results/)
    end
  end

  context 'search by critical flag' do
    render_views

    before do
      get :quota_search, params: { critical: 'Y' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Quota search results/)
    end
  end

  context 'search by status' do
    render_views

    before do
      get :quota_search, params: { status: 'Not blocked' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'displays results' do
      expect(response.body).to match(/Quota search results/)
    end
  end

  context 'search by year' do
    render_views

    before do
      get :quota_search, params: { years: '2019' }, format: :html
    end

    it { is_expected.to respond_with(:success) }

    it 'restricts search by years only' do
      expect(response.body).to match(/Sorry, there is a problem with the search query. Please specify one or more search criteria./)
    end
  end
end
