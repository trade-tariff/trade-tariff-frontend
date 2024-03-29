FactoryBot.define do
  factory :search_result, class: 'Beta::Search::SearchResult' do
    no_redirect
    with_intercept_message

    resource_id { '6fc22ae4ee7f6fbe9b4988a4557dd3f9' }
    took { 2 }
    timed_out { false }
    max_score { 76.975296 }
    total_results { 1097 }
    chapter_statistics { [attributes_for(:chapter_statistic)] }
    heading_statistics { [attributes_for(:heading_statistic)] }
    facet_filter_statistics { [attributes_for(:facet_filter_statistic, facet_count: 500)] }
    guide { attributes_for(:guide) }
    search_query_parser_result { attributes_for(:search_query_parser_result) }

    hits do
      [
        attributes_for(:chapter, resource_type: 'chapter'),
        attributes_for(:heading, resource_type: 'heading'),
        attributes_for(:subheading, resource_type: 'subheading'),
        attributes_for(:commodity, :with_ancestors, description: 'Pure-bred breeding animals'),
      ]
    end

    trait :no_redirect do
      direct_hit { nil }
    end

    trait :redirect do
      direct_hit { attributes_for(:heading, goods_nomenclature_item_id: '0101000000', producline_suffix: '80') }
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

    trait :with_facet_filter_statistics_above_and_below_threshold do
      total_results { 100 }
      facet_filter_statistics do
        [
          attributes_for(:facet_filter_statistic, facet_count: 4),
          attributes_for(:facet_filter_statistic, facet_count: 5),
          attributes_for(:facet_filter_statistic, facet_count: 6),
        ]
      end
    end

    trait :no_facets do
      facet_filter_statistics { [] }
    end

    trait :no_hits do
      hits { [] }
    end

    trait :no_guide do
      guide { nil }
    end

    trait :with_intercept_message do
      intercept_message { attributes_for(:intercept_message) }
    end

    trait :no_intercept_message do
      intercept_message {}
    end

    trait :spelling_corrected do
      search_query_parser_result { attributes_for(:search_query_parser_result, :corrected) }
    end

    trait :spelling_not_corrected do
      search_query_parser_result { attributes_for(:search_query_parser_result, :not_corrected) }
    end
  end
end
