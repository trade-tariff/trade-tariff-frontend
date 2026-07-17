class Search
  class HybridOutcome
    include ApiEntity

    attr_accessor :type

    def initialize(parsed_data)
      @results = Array(parsed_data).map { |attrs| build_model(attrs) }
      @type = exact_match? ? 'exact_match' : 'fuzzy_match'
    end

    def exact_match?
      @results.size == 1 && @results.first.score.nil?
    end

    def exact_match
      @results.first
    end

    def commodities
      @results
        .select { |r| r.is_a?(Commodity) && r.declarable }
        .first(TradeTariffFrontend.hybrid_results_to_show)
    end

    def entry
      if exact_match?
        { 'id' => exact_match.id, 'endpoint' => 'commodities' }
      end
    end

    def goods_nomenclature_match
      if @goods_nomenclature_match || exact_match?
        GoodsNomenclatureMatch::BLANK_RESULT
      else
        GoodsNomenclatureMatch.new(sections: [], chapters: [], headings: [], commodities: commodities)
      end
    end

    delegate :any?, to: :commodities
    def none? = !any?

    def reference_matches_by_chapter = []
    def gn_matches_without_duplicates_by_chapter = []
    def reference_match = ReferenceMatch::BLANK_RESULT
    def all = @results

    delegate :size, to: :all

    def interactive_search? = false

    def has_pending_question? = false

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
