RSpec.describe 'search/_interactive_results_content', type: :view do
  subject { render partial: 'search/interactive_results_content' }

  before do
    assign(:results, results)
    assign(:search, search)
  end

  let(:search) { Search.new(q: 'citrus jam', request_id: 'test-uuid-123', interactive_search: true) }
  let(:answered) do
    [
      { 'question' => 'What type of fruit?', 'options' => %w[Citrus Berry], 'answer' => 'Citrus' },
    ]
  end
  let(:meta) do
    {
      'interactive_search' => {
        'request_id' => 'test-uuid-123',
        'query' => 'citrus jam',
        'answers' => answered,
        'result_limit' => 5,
      },
    }
  end
  let(:results) do
    Search::InternalSearchResult.new(
      [
        {
          'goods_nomenclature_item_id' => '2007919930',
          'producline_suffix' => '80',
          'goods_nomenclature_class' => 'Commodity',
          'description' => 'Containing less than 70% by weight of sugar',
          'formatted_description' => 'Containing less than 70% by weight of sugar',
          'full_description' => 'Citrus fruit jam with less than 70% sugar',
          'heading_description' => 'Jams and marmalades',
          'declarable' => true,
          'score' => 15.5,
          'confidence' => 'strong',
        },
      ],
      meta,
    )
  end

  it { is_expected.to have_text('The results below are based on the details you supplied') }

  describe 'search playback' do
    it { is_expected.to have_css('details .govuk-details__summary-text', text: 'View search details') }
    it { is_expected.to have_text('Search term:') }
    it { is_expected.to have_text('citrus jam') }
    it { is_expected.to have_text('What type of fruit?') }
    it { is_expected.to have_text('Citrus') }
    it { is_expected.to have_css('button', text: 'Copy search details') }
  end

  describe 'warning panel' do
    it { is_expected.to have_css('.govuk-warning-text') }
    it { is_expected.to have_text('You are responsible for using the correct commodity codes') }
  end

  describe 'results subheading' do
    it { is_expected.to have_css('h2', text: 'Top search results') }
  end

  describe 'commodity links' do
    it { is_expected.to have_link('View this commodity code (opens in new tab)', href: /2007919930/) }

    it 'opens commodity links in a new tab' do
      render partial: 'search/interactive_results_content'

      expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]', text: 'View this commodity code (opens in new tab)')
    end
  end

  describe 'confidence meter' do
    it { is_expected.to have_css('.confidence-indicator') }
  end

  describe 'confidence explainer' do
    it { is_expected.to have_text('Strong result') }
    it { is_expected.to have_text('Good result') }
    it { is_expected.to have_text('Possible result') }
    it { is_expected.to have_text('Unlikely result') }
  end

  describe 'sidebar' do
    it { is_expected.to have_css('h2', text: 'Help and guidance') }
    it { is_expected.to have_css('.govuk-details__summary-text', text: 'Get support') }
  end
end
