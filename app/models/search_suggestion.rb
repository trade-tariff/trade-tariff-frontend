require 'api_entity'

class SearchSuggestion
  include ApiEntity

  CHEMICAL_TYPE = /(full_chemical_cas|full_chemical_cus|full_chemical_name)/
  REFERENCE_TYPE = 'search_reference'.freeze
  GOODS_NOMENCLATURE_TYPE = 'goods_nomenclature'.freeze

  PRESENTED_CHEMICAL_TYPE = 'Chemical'.freeze
  PRESENTED_REFERENCE_TYPE = 'Reference'.freeze

  attr_accessor :score,
                :query,
                :value,
                :suggestion_type,
                :priority,
                :goods_nomenclature_class

  def formatted_suggestion_type
    case suggestion_type
    when GOODS_NOMENCLATURE_TYPE
      goods_nomenclature_class.to_s.humanize
    when CHEMICAL_TYPE
      PRESENTED_CHEMICAL_TYPE
    when REFERENCE_TYPE
      ''
    else
      suggestion_type.to_s.humanize
    end
  end
end
