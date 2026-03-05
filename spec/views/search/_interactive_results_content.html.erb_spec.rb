RSpec.describe 'search/_interactive_results_content', type: :view do
  subject { render partial: 'search/interactive_results_content' }

  before do
    assign(:results, results)
    assign(:search, search)
  end

  let(:search) { Search.new(q: 'citrus jam', request_id: 'test-uuid-123', interactive_search: true) }
  let(:meta) do
    {
      'interactive_search' => {
        'request_id' => 'test-uuid-123',
        'query' => 'citrus jam',
        'answers' => [],
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

  it { is_expected.to have_link('View this commodity code (opens in new tab)', href: /2007919930/) }

  it 'opens commodity links in a new tab' do
    render partial: 'search/interactive_results_content'

    expect(rendered).to have_css('a[target="_blank"][rel="noopener noreferrer"]', text: 'View this commodity code (opens in new tab)')
  end

  it { is_expected.to have_css('.confidence-indicator') }
end
