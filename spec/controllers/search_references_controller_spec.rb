require 'spec_helper'

describe SearchReferencesController, 'GET to #show', type: :controller do
  render_views

  around do |example|
    VCR.use_cassette('a_z_index#show_m') do
      example.run
    end
  end

  before do
    get :show, params: { letter: 'm' }
  end

  it 'renders links to relevant headings' do
    expect(response.body).to include 'Mace'
    expect(response.body).to include '/headings/0908'
  end

  it 'renders links to relevant chapters' do
    expect(response.body).to include 'Melons'
    expect(response.body).to include '/chapters/08'
  end

  it 'renders links to relevant sections' do
    expect(response.body).to include 'Machine Tools'
    expect(response.body).to include '/sections/16'
  end

  it 'doesn\'t renders links to commodities' do
    expect(response.body).not_to include 'Mascarpone'
    expect(response.body).not_to include '/commodities/0406105090'
  end
end
