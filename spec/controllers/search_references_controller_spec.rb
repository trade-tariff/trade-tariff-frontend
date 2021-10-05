require 'spec_helper'

RSpec.describe SearchReferencesController, '#show', type: :controller do
  render_views

  around do |example|
    VCR.use_cassette('a_z_index#show_m') do
      example.run
    end
  end

  before do
    get :show, params: { letter: 'm' }
  end

  context 'when looking for the relevant headings' do
    it 'renders the Mace title' do
      expect(response.body).to include 'Mace'
    end

    it 'renders links to relevant headings' do
      expect(response.body).to include '/headings/0908'
    end
  end

  context 'when looking for the relevant chapters' do
    it 'renders the Melons title' do
      expect(response.body).to include 'Melons'
    end

    it 'renders links to relevant chapters' do
      expect(response.body).to include '/chapters/08'
    end
  end

  context 'when looking for the relevant sections' do
    it 'renders the Machine Tools title' do
      expect(response.body).to include 'Machine Tools'
    end

    it 'renders links to relevant sections' do
      expect(response.body).to include '/sections/16'
    end
  end

  context 'when looking for the relevant commodities' do
    it 'doesn\'t renders the Mascarpone title' do
      expect(response.body).not_to include 'Mascarpone'
    end

    it 'doesn\'t renders links to commodities' do
      expect(response.body).not_to include '/commodities/0406105090'
    end
  end
end
