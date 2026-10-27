RSpec.describe 'search/interactive_question', type: :view do
  subject { render }

  before do
    assign(:search, search)
    assign(:results, Search::InternalSearchResult.new([], meta))
  end

  let(:search) { Search.new('q' => 'citrus jam', 'request_id' => 'test-uuid-123', 'interactive_search' => true) }

  let(:meta) do
    {
      'interactive_search' => {
        'query' => 'citrus jam',
        'request_id' => 'test-uuid-123',
        'answers' => [
          { 'question' => 'What type of fruit?', 'options' => %w[Citrus Berry], 'answer' => nil },
        ],
        'expanded_query' => 'citrus fruit jam marmalade preserve',
      },
    }
  end

  it { is_expected.to have_css('h1', text: 'Search for a commodity') }
  it { is_expected.to have_css('span.govuk-caption-xl', text: 'UK Integrated Online Tariff') }
  it { is_expected.to have_link('Cancel', href: find_commodity_path) }

  it 'keeps the existing question content and controls' do
    render

    expect(rendered).to have_text('We need to ask you some questions about the products.')
    expect(rendered).to have_css('legend', text: 'What type of fruit?')
    expect(rendered).to have_field('Citrus', type: 'radio')
    expect(rendered).to have_field('Berry', type: 'radio')
    expect(rendered).to have_css('.govuk-radios__divider')
    expect(rendered).to have_field("I don't know", type: 'radio')
    expect(rendered).to have_button('Submit')
  end

  context 'when reached from the Duty Calculator journey' do
    before do
      allow(view).to receive(:params).and_return(ActionController::Parameters.new(duty_calculator: 'true'))
      assign(:duty_calculator_preselected_answer, 'Citrus')
    end

    it 'uses the calculator caption and keeps navigation inside the journey', :aggregate_failures do
      render

      expect(rendered).to have_css('span.govuk-caption-xl', text: 'Calculate import costs')
      expect(rendered).to have_link('Back', href: what_are_you_importing_path)
      expect(rendered).to have_link('Cancel', href: what_are_you_importing_path)
      expect(rendered).to have_field('duty_calculator', type: 'hidden', with: 'true')
      expect(rendered).to have_checked_field('interactive-search-form-answer-citrus-field')
    end
  end

  it 'carries the expanded query into the answer submission form' do
    render

    expect(rendered).to have_css(
      'input[type="hidden"][name="expanded_query"][value="citrus fruit jam marmalade preserve"]',
      visible: :hidden,
    )
  end

  it 'carries expansion terms as escaped JSON', :aggregate_failures do
    meta['interactive_search']['query_expansion'] = { 'ai_terms' => ['horse "mare" & <foal>'] }

    render

    field = Capybara.string(rendered).find('input[name="query_expansion"]', visible: :hidden)
    expect(JSON.parse(field.value)).to eq('ai_terms' => ['horse "mare" & <foal>'])
    expect(rendered).to include('&quot;').and include('&lt;')
  end

  it 'carries a known-empty expansion term list' do
    meta['interactive_search']['query_expansion'] = { 'ai_terms' => [] }

    render

    field = Capybara.string(rendered).find('input[name="query_expansion"]', visible: :hidden)
    expect(field.value).to eq('{"ai_terms":[]}')
  end

  it 'omits unknown expansion data from the answer form' do
    render

    expect(rendered).not_to have_css('input[name="query_expansion"]', visible: :all)
  end

  it 'carries only a present experiment label into the answer form' do
    allow(view).to receive(:search_form_path).and_return('/find_commodity')
    assign(:search, Search.new(q: 'jam', request_id: '123', interactive_search: true, experiment: 'trstd-trdr'))
    render
    expect(rendered).to have_css('input[name="experiment"][value="trstd-trdr"]', visible: :hidden)
  end

  context 'when the guided search was started for a historical date' do
    let(:search) do
      Search.new(
        'q' => 'citrus jam',
        'request_id' => 'test-uuid-123',
        'interactive_search' => true,
        'day' => '27',
        'month' => '3',
        'year' => '2021',
      )
    end

    it 'carries the date into the answer submission form' do
      render

      expect(rendered)
        .to have_css('input[type="hidden"][name="day"][value="27"]', visible: :hidden)
        .and have_css('input[type="hidden"][name="month"][value="3"]', visible: :hidden)
        .and have_css('input[type="hidden"][name="year"][value="2021"]', visible: :hidden)
    end
  end
end
