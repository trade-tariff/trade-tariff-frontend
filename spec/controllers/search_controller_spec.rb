require 'spec_helper'

describe SearchController, "GET to #search", type: :controller do
  include CrawlerCommons

  context 'with HTML format' do
    context 'with search term' do
      context "with exact match query", vcr: { cassette_name: "search#search_exact" }  do
        let(:query) { "01" }

        before(:each) do
          get :search, params: { q: query }
        end

        it { should respond_with(:redirect) }
        it { expect(assigns(:search)).to be_a(Search) }
        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query
        end
      end

      context "with fuzzy match query", vcr: { cassette_name: "search#search_fuzzy" }  do
        let(:query) { "horses" }

        before(:each) do
          get :search, params: { q: query }
        end

        it { should respond_with(:success) }
        it { expect(assigns(:search)).to be_a(Search) }
        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query
        end
      end

      context "with blank match",  vcr: { cassette_name: "search#blank_match" } do
        render_views

        let(:query) { " !such string should not exist in the database! " }

        before(:each) do
          get :search, params: { q: query }
        end

        it { should respond_with(:success) }
        it { expect(assigns(:search)).to be_a(Search) }
        it 'assigns search attribute' do
          expect(assigns[:search].q).to eq query
        end
        it "should display no results" do
          expect(response.body).to match /no results/
        end
      end
    end

    context 'without search term', vcr: { cassette_name: "search#blank_match" }  do
      let(:now) { Time.now.utc }
      context 'changing browse date' do
        context 'valid past date params provided' do
          let(:year)    { now.year - 1 }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before(:each) do
            @request.env['HTTP_REFERER'] = "/#{APP_SLUG}/chapters/01"

            post :search, params: {
              year: year,
              month: month,
              day: day
            }
          end

          it { should respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { should redirect_to(chapter_path("01", year: year, month: month, day: day)) }
        end

        context 'valid future date params provided and currency is forced to EUR' do
          let(:future_date) { Date.today + 10.months }
          let(:year)    { future_date.year }
          let(:month)   { future_date.month }
          let(:day)     { future_date.day }

          before(:each) do
            @request.env['HTTP_REFERER'] = "/#{APP_SLUG}/chapters/01"

            post :search, params: {
              year: year,
              month: month,
              day: day
            }
          end

          it { should respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { should redirect_to(chapter_path("01", currency: "EUR", year: year, month: month, day: day)) }
        end

        context 'valid date params provided for today' do
          let(:year)    { now.year }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before(:each) do
            @request.env['HTTP_REFERER'] = "/#{APP_SLUG}/chapters/01"

            post :search, params: {
              year: year,
              month: month,
              day: day
            }
          end

          it { should respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { should redirect_to(chapter_path("01") + '?') }
        end

        context 'valid past date time param(as_of) provided' do
          let(:year)    { now.year - 1 }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before(:each) do
            @request.env['HTTP_REFERER'] = "/#{APP_SLUG}/chapters/01"

            post :search, params: {
              as_of: "#{year}-#{month}-#{day}"
            }
          end

          it { should respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { should redirect_to(chapter_path("01", year: year, month: month, day: day)) }
        end

        context 'valid future date time param(as_of) provided and currency is forced to EUR' do
          let(:year)    { now.year + 1 }
          let(:month)   { now.month }
          let(:day)     { now.day }

          before(:each) do
            @request.env['HTTP_REFERER'] = "/#{APP_SLUG}/chapters/01"

            post :search, params: {
              as_of: "#{year}-#{month}-#{day}"
            }
          end

          it { should respond_with(:redirect) }
          it { expect(assigns(:search)).to be_a(Search) }
          it { should redirect_to(chapter_path("01", currency: 'EUR', year: year, month: month, day: day)) }
        end

        context 'invalid date param provided' do
          context 'date param is a string' do
            before(:each) do
              post :search, params: { date: "2012-10-1" }
            end

            it { should respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { should redirect_to(sections_path) }
          end

          context 'date param does not have all components present' do
            let(:year)    { Forgery(:date).year }
            let(:month)   { Forgery(:date).month(numerical: true) }

            before(:each) do
              post :search, params: { date: {
                year: year,
                month: month,
              } }
            end

            it { should respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { should redirect_to(sections_path) }
          end

          context 'date param components are invalid' do
            let(:year)    { 'errr' }
            let(:month)   { 'er' }
            let(:day)     { 'er' }

            before(:each) do
              post :search, params: { date: {
                year: year,
                month: month,
                day: day
              } }
            end

            it { should respond_with(:redirect) }
            it { expect(assigns(:search)).to be_a(Search) }
            it { should redirect_to(sections_path) }
          end
        end
      end
    end
  end

  context 'with JSON format', vcr: { cassette_name: "search#search_fuzzy" } do
    let(:query) { "horses" }

    before(:each) do
      get :search, params: { q: query }, format: :json
    end

    let(:body) { JSON.parse(response.body) }

    describe 'returns search suggestions as specified in OpenSearch Suggestion extension' do
      specify 'returns an Array' do
        expect(body).to be_kind_of Array
      end

      specify 'first argument in Array is search query' do
        expect(body.first).to eq query
      end

      specify 'second argument in Array is Array of suggestions' do
        expect(body.second).to be_kind_of Array
        expect(body.second.first).to eq 'Meat Of Horses, Asses, Mules Or Hinnies, Fresh, Chilled Or Frozen'
      end
    end
  end

  context 'with ATOM format', vcr: { cassette_name: "search#search_fuzzy" } do
    render_views

    let(:query) { "horses" }

    before(:each) do
      get :search, params: { q: query }, format: :atom
    end

    describe 'returns search suggestion in ATOM 1.0 format' do
      specify 'includes link to current page (self link)' do
        expect(response.body).to include 'trade-tariff/search.atom'
      end

      specify 'includes link to opensearch.xml file (search link)' do
        expect(response.body).to include 'trade-tariff/opensearch.xml'
      end

      specify 'includes commodity descriptions' do
        expect(response.body).to include 'Of horses, asses, mules and hinnies'
      end

      specify 'includes links to commodity pages' do
        expect(response.body).to include 'trade-tariff/commodities/0206809100'
      end
    end
  end

  describe "header for crawlers", vcr: { cassette_name: "search#blank_match" } do
    context "non historical" do
      before { get :search }
      it { should_not_include_robots_tag! }
    end

    context "historical" do
      before { historical_request :search }
      it { should_include_robots_tag! }
    end
  end
end

describe SearchController, "GET to #codes", type: :controller do
  describe "GET to #suggestions", vcr: { cassette_name: 'search#suggestions', allow_playback_repeats: true } do
    let!(:suggestions) { SearchSuggestion.all }
    let!(:suggestion) { suggestions[0] }
    let!(:query) { suggestion.value.to_s }

    context 'with term param' do
      before(:each) do
        get :suggestions, params: { term: query }, format: :json
      end

      let(:body) { JSON.parse(response.body) }

      specify 'returns an Array' do
        expect(body['results']).to be_kind_of(Array)
      end

      specify 'includes search results' do
        expect(body['results']).to include({'id' => suggestion.value, 'text' => suggestion.value})
      end
    end

    context 'without term param' do
      before(:each) do
        get :suggestions, format: :json
      end

      let(:body) { JSON.parse(response.body) }

      specify 'returns an Array' do
        expect(body['results']).to be_kind_of(Array)
      end
    end
  end
end

describe SearchController, "GET to #quota_search", type: :controller, vcr: { cassette_name: 'search#quota_search', allow_playback_repeats: true } do

  context 'without search params' do
    render_views

    before(:each) do
      get :quota_search, format: :html
    end

    it { should respond_with(:success) }
    it 'should display no results' do
      expect(response.body).not_to match /Quota search results/
    end
  end

  context 'without search params' do
    render_views

    before(:each) do
      get :quota_search, format: :html
    end

    it { should respond_with(:success) }
    it 'should display no results' do
      expect(response.body).not_to match /Quota search results/
    end
  end

  context 'search by goods nomenclature' do
    render_views
  
    before(:each) do
      get :quota_search, params: {goods_nomenclature_item_id: '0301919011'}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

  context 'search by origin' do
    render_views
  
    before(:each) do
      get :quota_search, params: {geographical_area_id: '1011'}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

  context 'search by order number' do
    render_views
  
    before(:each) do
      get :quota_search, params: {order_number: '090671'}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

  context 'search by critical flag' do
    render_views
  
    before(:each) do
      get :quota_search, params: {critical: 'Y'}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

  context 'search by status' do
    render_views
  
    before(:each) do
      get :quota_search, params: {status: 'Blocked'}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

  context 'search by multiple years' do
    render_views
  
    before(:each) do
      get :quota_search, params: {year: %w(2018 2019)}, format: :html
    end
  
    it { should respond_with(:success) }
    it 'should display results' do
      expect(response.body).to match /Quota search results/
    end
  end

end
