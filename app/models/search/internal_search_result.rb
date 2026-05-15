class Search
  class InternalSearchResult
    CONTROLLER_MAP = {
      'Chapter' => 'chapters',
      'Heading' => 'headings',
      'Commodity' => 'commodities',
      'Subheading' => 'subheadings',
    }.freeze
    KNOWN_CONFIDENCE_LEVELS = %w[strong good possible unlikely].freeze

    attr_reader :type, :meta

    def initialize(parsed_data, meta = nil)
      @results = Array(parsed_data).map { |attrs| build_model(attrs) }
      @type = @results.empty? ? nil : 'internal'
      @meta = meta
    end

    def exact_match?
      @results.size == 1 && @results.first.score.nil?
    end

    def to_param
      return {} unless exact_match?

      result = @results.first
      gn_class = result.attributes['goods_nomenclature_class'] || result.class.name
      {
        controller: CONTROLLER_MAP[gn_class] || 'commodities',
        action: :show,
        id: result.to_param,
      }
    end

    delegate :any?, :none?, to: :@results

    def commodities
      @results
        .select { |r| r.is_a?(Commodity) && r.declarable }
        .first(TradeTariffFrontend.legacy_results_to_show)
    end

    def reference_matches_by_chapter = []
    def gn_matches_without_duplicates_by_chapter = []
    def reference_match = ReferenceMatch::BLANK_RESULT
    def goods_nomenclature_match = GoodsNomenclatureMatch::BLANK_RESULT
    def all = @results

    delegate :size, to: :all

    def confident_results
      @results.select { |r| r.try(:confidence).present? }
    end

    def all_unknown_confidence?
      any? && @results.none? do |result|
        KNOWN_CONFIDENCE_LEVELS.include?(result.try(:confidence).to_s.downcase)
      end
    end

    def interactive_search?
      meta&.dig('interactive_search').present?
    end

    def has_pending_question?
      return false unless interactive_search?

      all_answers = meta.dig('interactive_search', 'answers') || []
      all_answers.any? && all_answers.last['answer'].nil?
    end

    def current_question
      return nil unless has_pending_question?

      all_answers = meta.dig('interactive_search', 'answers')
      all_answers.last
    end

    def request_id
      meta&.dig('interactive_search', 'request_id')
    end

    def answered_questions
      all_answers = meta&.dig('interactive_search', 'answers') || []
      all_answers.select { |a| a['answer'].present? }
    end

    def result_limit
      meta&.dig('interactive_search', 'result_limit') || 5
    end

    def query
      meta&.dig('interactive_search', 'query')
    end

    def description_intercept
      meta&.dig('description_intercept')
    end

    def blocking_guidance?
      di = description_intercept
      return false unless di

      ActiveModel::Type::Boolean.new.cast(di['excluded']) &&
        di['message_header'].present? &&
        di['message'].present?
    end

    def description_intercept_message_header
      description_intercept&.dig('message_header')
    end

    def description_intercept_message
      description_intercept&.dig('message')
    end

    def description_intercept_term
      description_intercept&.dig('term')
    end

    private

    def build_model(entry)
      gn_class = entry['goods_nomenclature_class']
      klass = begin
        gn_class.constantize
      rescue StandardError
        GoodsNomenclature
      end
      klass.new(entry)
    end
  end
end
