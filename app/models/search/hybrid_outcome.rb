class Search
  class HybridOutcome
    include ApiEntity

    attr_accessor :entry, :type

def initialize(parsed_data)
  @results = Array(parsed_data).map { |attrs| build_model(attrs) }
  @type = 'internal'
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

    delegate :any?, :none?, to: :@results

    def reference_matches_by_chapter = []
    def gn_matches_without_duplicates_by_chapter = []
    def reference_match = ReferenceMatch::BLANK_RESULT
    def goods_nomenclature_match = GoodsNomenclatureMatch::BLANK_RESULT
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
