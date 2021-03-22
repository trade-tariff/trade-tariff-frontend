require 'spec_helper'

# TODO: Write necessary and sufficient tests of this model
xdescribe GeographicalAreasController, 'GET to #index', type: :controller, vcr: { cassette_name: 'geographical_areas#countries', record: :new_cassettes, allow_playback_repeats: true } do
  let!(:areas) { GeographicalArea.all }
  let!(:area) { areas[0] }
  let!(:query) { area.long_description.to_s }

  context 'with term param' do
    before do
      get :index, params: { term: query }, format: :json
    end

    let(:body) { JSON.parse(response.body) }

    specify 'returns an Array' do
      expect(body['results']).to be_kind_of(Array)
    end

    specify 'includes search results' do
      expect(body['results']).to include({ 'id' => area.id, 'text' => area.long_description })
    end
  end

  context 'without term param' do
    before do
      get :index, format: :json
    end

    let(:body) { JSON.parse(response.body) }

    specify 'returns an Array' do
      expect(body['results']).to be_kind_of(Array)
    end
  end
end
