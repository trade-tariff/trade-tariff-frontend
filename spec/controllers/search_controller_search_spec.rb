require 'spec_helper'

RSpec.describe SearchController, type: :controller do
  include CrawlerCommons

  describe 'GET #search' do
    subject(:do_response) { get :search, params: }

    context 'when using beta search' do
      let(:params) { { q: 'clothing', filter: { material: 'leather' } } }
      let(:search_result) { build(:search_result) }

      before do
        allow(controller).to receive(:beta_search_enabled?).and_return(true)
        perform_search_service = instance_double('Beta::Search::PerformSearchService', call: search_result)
        allow(Beta::Search::PerformSearchService).to receive(:new).and_return(perform_search_service)
      end

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('beta/search_results/show') }

      it 'calls the PerformSearchService' do
        do_response

        expect(Beta::Search::PerformSearchService).to have_received(:new).with(
          { q: 'clothing', spell: '1' },
          { 'material' => 'leather' },
        )
      end

      context 'when redirected' do
        let(:params) { { q: '0101', year: '2022', month: '11', day: '1', country: 'IN' } }

        let(:search_result) { build(:search_result, :redirect) }

        it { is_expected.to redirect_to(heading_path('0101', year: '2022', month: '11', day: '1', country: 'IN')) }
      end
    end
  end

  context 'with HTML format' do
    context 'with search term' do
      before do
        get :search, params: { q: query }
      end

      context 'with exact match query', vcr: { cassette_name: 'search#search_exact' } do
        let(:query) { '01' }

        it { is_expected.to redirect_to commodity_path('0101210000') }
        it { expect(assigns(:search)).to be_a(Search) }

        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query
        end
      end

      context 'with fuzzy match query', vcr: { cassette_name: 'search#search_fuzzy' } do
        let(:query) { 'horses' }

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:search)).to be_a(Search) }

        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query
        end
      end

      context 'with blank match', vcr: { cassette_name: 'search#blank_match' } do
        render_views

        let(:query) { ' !such string should not exist in the database! ' }

        it { is_expected.to respond_with(:success) }
        it { expect(assigns(:search)).to be_a(Search) }

        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query.strip
        end

        it 'displays no results' do
          expect(response.body).to match(/no results/)
        end
      end

      context 'with unknown commodity code', vcr: { cassette_name: 'search#blank_match' } do
        let(:query) { '0123456789' }

        it { is_expected.to redirect_to commodity_path(query) }
      end

      context 'with heading code', vcr: { cassette_name: 'search#blank_match' } do
        let(:query) { '0123' }

        it { is_expected.to redirect_to heading_path(query) }
      end
    end

    context 'with nested search term',
            vcr: { cassette_name: 'search#search_exact' } do
      before { get :search, params: { search: { q: '01' } } }

      it { expect(assigns[:search]).to have_attributes q: '01' }
      it { is_expected.to redirect_to commodity_path('0101210000') }
    end

    context 'without search term', vcr: { cassette_name: 'search#blank_match' } do
      let(:now) { Time.zone.now.utc }

      context 'when changing browse date' do
        context 'when valid past date params provided' do
          let(:year)    { now.year - 1 }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before do
            @request.env['HTTP_REFERER'] = '/chapters/01'

            post :search, params: {
              year:,
              month:,
              day:,
            }
          end

          it { is_expected.to respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { is_expected.to redirect_to(chapter_path('01', day:, month:, year:)) }
        end

        context 'when valid date params provided for today' do
          let(:year)    { now.year }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before do
            @request.env['HTTP_REFERER'] = '/chapters/01'

            post :search, params: {
              year:,
              month:,
              day:,
            }
          end

          it { is_expected.to respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { is_expected.to redirect_to("#{chapter_path('01')}?") }
        end

        context 'when invalid date param provided' do
          context 'when date param is a string' do
            before do
              post :search, params: { date: '2012-10-1' }
            end

            it { is_expected.to respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { is_expected.to redirect_to(sections_path) }
          end

          context 'when date param does not have all components present' do
            let(:year)    { Forgery(:date).year }
            let(:month)   { Forgery(:date).month(numerical: true) }

            before do
              post :search, params: { date: {
                year:,
                month:,
              } }
            end

            it { is_expected.to respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { is_expected.to redirect_to(sections_path) }
          end

          context 'when date param components are invalid' do
            let(:year)    { 'errr' }
            let(:month)   { 'er' }
            let(:day)     { 'er' }

            before do
              post :search, params: { date: {
                year:,
                month:,
                day:,
              } }
            end

            it { is_expected.to respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { is_expected.to redirect_to(sections_path) }
          end
        end
      end
    end
  end

  context 'with JSON format', vcr: { cassette_name: 'search#search_fuzzy', match_requests_on: %i[uri body] } do
    let(:day) { '5' }
    let(:month) { '4' }
    let(:year) { '2019' }

    describe 'common fields' do
      let(:query) { 'car parts' }

      before do
        get :search, params: { q: query, day:, month:, year: }, format: :json
      end

      specify 'should return query and date within response body' do
        body = JSON.parse(response.body)

        expect(body).to be_kind_of Hash
        expect(body['q']).to eq(query)
        expect(body['as_of']).to eq(Date.new(year.to_i, month.to_i, day.to_i).to_formatted_s('YYYY-MM-DD'))
      end
    end

    describe 'exact match search result' do
      let(:query) { '2204' }

      before do
        get :search, params: { q: query, day:, month:, year: }, format: :json
      end

      specify 'should return single goods nomenclature' do
        body = JSON.parse(response.body)

        expect(body['results'].size).to eq(1)
        heading = body['results'].first
        expect(heading['goods_nomenclature_item_id']).to start_with(query)
      end
    end

    describe 'search references exact match search result' do
      let(:query) { 'account books' }

      before do
        get :search, params: { q: query, day:, month:, year: }, format: :json
      end

      specify 'should return single goods nomenclature' do
        body = JSON.parse(response.body)

        expect(body['results'].size).to eq(1)
        heading = body['results'].first
        expect(heading['goods_nomenclature_item_id']).to eq('4820000000')
      end
    end

    describe 'fuzzy match search result' do
      let(:query) { 'minerals' }

      before do
        get :search, params: { q: query, day:, month:, year: }, format: :json
      end

      specify 'should return single goods nomenclature' do
        body = JSON.parse(response.body)

        expect(body['results'].size).to be > 1
      end
    end

    describe 'empty search result' do
      let(:query) { 'designed velocycles' }

      before do
        get :search, params: { q: query, day:, month:, year: }, format: :json
      end

      specify 'should return single goods nomenclature' do
        body = JSON.parse(response.body)

        expect(body['results'].size).to eq(0)
      end
    end
  end

  context 'with ATOM format', vcr: { cassette_name: 'search#search_fuzzy' } do
    render_views

    let(:query) { 'horses' }

    before do
      get :search, params: { q: query }, format: :atom
    end

    describe 'returns search suggestion in ATOM 1.0 format' do
      specify 'includes link to current page (self link)' do
        expect(response.body).to include '/search.atom'
      end

      specify 'includes link to opensearch.xml file (search link)' do
        expect(response.body).to include '/opensearch.xml'
      end

      specify 'includes commodity descriptions' do
        expect(response.body).to include 'Of horses, asses, mules and hinnies'
      end

      specify 'includes links to commodity pages' do
        expect(response.body).to include '/commodities/0206809100'
      end
    end
  end

  describe 'header for crawlers', vcr: { cassette_name: 'search#blank_match' } do
    context 'when non historical' do
      before { get :search }

      it { should_not_include_robots_tag! }
    end

    context 'when historical' do
      before { historical_request :search }

      it { should_include_robots_tag! }
    end
  end
end
