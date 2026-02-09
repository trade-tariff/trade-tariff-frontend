RSpec.describe SearchController, type: :controller do
  include CrawlerCommons

  describe 'GET #search' do
    subject(:do_response) { get :search, params: }

    context 'with exact match query', vcr: { cassette_name: 'search#search_exact' } do
      before { do_response }

      let(:params) { { q: '01' } }

      it { is_expected.to have_http_status(:redirect) }
      it { expect(assigns(:search)).to be_a(Search) }
      it { expect(assigns[:search].q).to eq '01' }

      it { expect(response.location).to include(chapter_path('01')) }
      it { expect(response.location).to include('request_id=') }
    end

    describe 'request_id propagation' do
      context 'when request_id is not provided', vcr: { cassette_name: 'search#search_fuzzy' } do
        let(:params) { { q: 'horses', day: '11', month: '05', year: '2023' } }

        before { do_response }

        it { expect(assigns(:search).request_id).to be_present }
        it { expect(assigns(:search).request_id).to match(/\A[0-9a-f-]{36}\z/) }
      end

      context 'when request_id is provided', vcr: { cassette_name: 'search#search_fuzzy' } do
        let(:params) { { q: 'horses', day: '11', month: '05', year: '2023', request_id: 'existing-uuid-123' } }

        before { do_response }

        it 'preserves the provided request_id' do
          expect(assigns(:search).request_id).to eq('existing-uuid-123')
        end
      end
    end

    context 'with fuzzy match query', vcr: { cassette_name: 'search#search_fuzzy' } do
      before { do_response }

      let(:params) { { q: 'horses', day: '11', month: '05', year: '2023' } }

      it { is_expected.to have_http_status(:ok) }
      it { expect(assigns(:search)).to be_a(Search) }
      it { expect(assigns[:search].q).to eq 'horses' }
    end

    context 'with blank match', vcr: { cassette_name: 'search#blank_match' } do
      render_views
      before { do_response }

      let(:params) { { q: ' !such string should not exist in the database! ' } }

      it { is_expected.to have_http_status(:ok) }
      it { expect(assigns(:search)).to be_a(Search) }
      it { expect(assigns[:search].q).to eq '!such string should not exist in the database!' }
      it { expect(response.body).to match(/no results/) }
    end

    context 'with commodity code', vcr: { cassette_name: 'search#blank_match' } do
      before { do_response }

      let(:params) { { q: '0123456789' } }

      it { is_expected.to have_http_status(:redirect) }

      it { expect(response.location).to include(commodity_path('0123456789')) }
      it { expect(response.location).to include('request_id=') }
    end

    context 'with heading code', vcr: { cassette_name: 'search#blank_match' } do
      before { do_response }

      let(:params) { { q: '0123' } }

      it { is_expected.to have_http_status(:redirect) }

      it { expect(response.location).to include(heading_path('0123')) }
      it { expect(response.location).to include('request_id=') }
    end

    context 'with nested search term', vcr: { cassette_name: 'search#search_exact' } do
      let(:params) { { search: { q: '01' } } }

      before { do_response }

      it { expect(assigns[:search]).to have_attributes q: '01' }

      it { is_expected.to have_http_status(:redirect) }
      it { expect(response.location).to include(chapter_path('01')) }
      it { expect(response.location).to include('request_id=') }
    end

    context 'without search term', vcr: { cassette_name: 'search#blank_match' } do
      subject(:do_response) do
        request.env['HTTP_REFERER'] = request_referer if request_referer.present?

        post :search, params: { year:, month:, day: }

        response
      end

      before { do_response }

      let(:now) { Time.zone.now.utc }
      let(:request_referer) { nil }

      context 'when valid past date params provided', vc: { cassette_name: 'search#blank_match' } do
        let(:request_referer) { chapter_path('01') }
        let(:year)    { now.year - 1 }
        let(:month)   { now.month }
        let(:day)     { now.day }

        it { is_expected.to have_http_status(:redirect) }
        it { expect(assigns(:search)).to be_a(Search) }
        it { is_expected.to redirect_to(chapter_path('01', day:, month:, year:)) }
      end

      context 'when valid date params provided for today' do
        let(:request_referer) { chapter_path('01') }
        let(:year)    { now.year }
        let(:month)   { now.month }
        let(:day)     { now.day }

        it { is_expected.to have_http_status(:redirect) }
        it { expect(assigns(:search)).to be_a(Search) }
        it { is_expected.to redirect_to("#{chapter_path('01')}?") }
      end

      context 'when date param is a string' do
        subject(:do_response) do
          post :search, params: { date: '2012-10-1' }

          response
        end

        it { is_expected.to have_http_status(:redirect) }
        it { expect(assigns(:search)).to be_a(Search) }
        it { is_expected.to redirect_to(sections_path) }
      end

      context 'when date param does not have all components present' do
        let(:year)    { Forgery(:date).year }
        let(:month)   { Forgery(:date).month(numerical: true) }
        let(:day)     { nil }

        it { is_expected.to have_http_status(:redirect) }
        it { expect(assigns(:search)).to be_a(Search) }
        it { is_expected.to redirect_to(sections_path) }
      end
    end

    context 'with JSON format', vcr: { cassette_name: 'search#search_fuzzy', match_requests_on: %i[uri body_without_request_id] } do
      let(:day) { '5' }
      let(:month) { '4' }
      let(:year) { '2019' }

      describe 'common fields' do
        let(:query) { 'car parts' }

        before do
          get :search, params: { q: query, day:, month:, year: }, format: :json
        end

        specify 'should return query and date within response body' do
          pattern = {
            'q' => 'car parts',
            'as_of' => '2019-04-05',
            'results' => be_a(Array),
          }
          expect(JSON.parse(response.body)).to include(pattern)
        end
      end

      describe 'exact match search result' do
        let(:query) { '22' }

        before do
          get :search, params: { q: query, day:, month:, year: }, format: :json
        end

        specify 'should return single goods nomenclature' do
          goods_nomenclature_item_ids = JSON.parse(response.body)['results']
            .map { |h| h['goods_nomenclature_item_id'] }

          expect(goods_nomenclature_item_ids).to eq(%w[2200000000])
        end
      end

      describe 'search references exact match search result' do
        let(:query) { 'ricotta' }

        before do
          get :search, params: { q: query, day:, month:, year: }, format: :json
        end

        specify 'should return single goods nomenclature' do
          goods_nomenclature_item_ids = JSON.parse(response.body)['results']
            .map { |h| h['goods_nomenclature_item_id'] }

          expect(goods_nomenclature_item_ids).to eq(%w[0406105090])
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

    context 'with ATOM format', vcr: { cassette_name: 'search#search_fuzzy', match_requests_on: %i[uri body_without_request_id] } do
      render_views

      let(:query) { 'horses' }

      before do
        get :search, params: { q: query, day: '11', month: '5', year: '2023' }, format: :atom
      end

      specify 'includes link to current page (self link)' do
        expect(response.body).to include '/search.atom'
      end

      specify 'includes commodity descriptions' do
        expect(response.body).to include 'Of horses, asses, mules and hinnies'
      end

      specify 'includes links to commodity pages' do
        expect(response.body).to include '/commodities/0206809100'
      end
    end

    context 'with internal interactive search' do
      subject(:do_response) { get :search, params: }

      let(:commodity_data) do
        {
          'id' => '123',
          'type' => 'commodity',
          'attributes' => {
            'goods_nomenclature_item_id' => '0101210000',
            'producline_suffix' => '80',
            'goods_nomenclature_class' => 'Commodity',
            'description' => 'Pure-bred breeding animals',
            'formatted_description' => 'Pure-bred breeding animals',
            'declarable' => true,
            'score' => 12.5,
          },
        }
      end

      before do
        allow(TradeTariffFrontend).to receive(:internal_search_enabled?).and_return(true)
      end

      context 'when backend returns a pending question' do
        let(:params) { { q: 'horses', internal_search: 'true' } }

        before do
          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: {
              'data' => [commodity_data],
              'meta' => {
                'interactive_search' => {
                  'query' => 'horses',
                  'request_id' => 'abc-123',
                  'result_limit' => 5,
                  'answers' => [
                    { 'question' => 'What type of horse?', 'options' => %w[Racing Breeding], 'answer' => nil },
                  ],
                },
              },
            }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          )
          do_response
        end

        it { is_expected.to have_http_status(:ok) }
        it { is_expected.to render_template(:interactive_question) }
      end

      context 'when all questions are answered' do
        let(:params) do
          {
            q: 'horses',
            internal_search: 'true',
            request_id: 'abc-123',
            answers: [
              { question: 'What type of horse?', options: %w[Racing Breeding], answer: 'Breeding' },
            ],
          }
        end

        before do
          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: {
              'data' => [commodity_data],
              'meta' => {
                'interactive_search' => {
                  'query' => 'horses',
                  'request_id' => 'abc-123',
                  'result_limit' => 5,
                  'answers' => [
                    { 'question' => 'What type of horse?', 'options' => %w[Racing Breeding], 'answer' => 'Breeding' },
                  ],
                },
              },
            }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          )
          do_response
        end

        it { is_expected.to have_http_status(:ok) }
        it { is_expected.to render_template(:interactive_results) }
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
end
