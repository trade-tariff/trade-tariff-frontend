require 'api_entity'

class SearchSuggestion
  include ApiEntity

  CHEMICAL_TYPE = /(full_chemical_cas|full_chemical_cus|full_chemical_name)/
  REFERENCE_TYPE = 'search_reference'.freeze
  GOODS_NOMENCLATURE_TYPE = 'goods_nomenclature'.freeze

  PRESENTED_CHEMICAL_TYPE = 'Chemical'.freeze
  PRESENTED_REFERENCE_TYPE = 'Reference'.freeze
  PRESENTED_GOODS_NOMENCLATURE_CHAPTER_TYPE = 'Chapter'.freeze
  PRESENTED_GOODS_NOMENCLATURE_HEADING_TYPE = 'Heading'.freeze
  PRESENTED_GOODS_NOMENCLATURE_COMMODITY_TYPE = 'Commodity'.freeze
  collection_path '/search_suggestions'

  attr_accessor :score,
                :query,
                :value,
                :suggestion_type,
                :priority

  def formatted_suggestion_type
    case suggestion_type
    when GOODS_NOMENCLATURE_TYPE
      goods_nomenclature_type
    when CHEMICAL_TYPE
      PRESENTED_CHEMICAL_TYPE
    when REFERENCE_TYPE
      PRESENTED_REFERENCE_TYPE
    else
      suggestion_type.to_s.humanize
    end
  end

  private

  def goods_nomenclature_type
    case value
    when /\A\d{2}\z/
      PRESENTED_GOODS_NOMENCLATURE_CHAPTER_TYPE
    when /\A\d{4}\z/
      PRESENTED_GOODS_NOMENCLATURE_HEADING_TYPE
    else
      PRESENTED_GOODS_NOMENCLATURE_COMMODITY_TYPE
    end
  end
end
