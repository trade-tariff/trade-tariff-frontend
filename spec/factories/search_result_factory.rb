FactoryBot.define do
  factory :search_result, class: 'Beta::Search::SearchResult' do
    no_redirect

    resource_id { '6fc22ae4ee7f6fbe9b4988a4557dd3f9' }
    took { 2 }
    timed_out { false }
    max_score { 76.975296 }
    total_results { 1097 }
    chapter_statistics { [attributes_for(:chapter_statistic)] }
    heading_statistics { [attributes_for(:heading_statistic)] }
    facet_filter_statistics { [attributes_for(:facet_filter_statistic)] }
    guide { attributes_for(:guide) }
    search_query_parser_result { attributes_for(:search_query_parser_result) }

    hits do
      [
        attributes_for(:chapter, resource_type: 'chapter'),
        attributes_for(:heading, resource_type: 'heading'),
        attributes_for(:subheading, resource_type: 'subheading'),
        attributes_for(:commodity, resource_type: 'commodity'),
      ]
    end

    trait :no_redirect do
      meta do
        {
          'redirect' => false,
          'redirect_to' => '',
        }
      end
    end

    trait :redirect do
      meta do
        {
          'redirect' => true,
          'redirect_to' => 'https://example.com/headings/0101',
        }
      end
    end

    trait :multiple_headings_view do
      heading_statistics do
        [
          attributes_for(:heading_statistic),
          attributes_for(:heading_statistic),
          attributes_for(:heading_statistic),
          attributes_for(:heading_statistic),
          attributes_for(:heading_statistic),
        ]
      end
    end

    trait :no_facets do
      facet_filter_statistics { [] }
    end
  end
end