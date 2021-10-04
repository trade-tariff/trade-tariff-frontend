require 'api_entity'

class Measure
  include ApiEntity

  attr_accessor :id,
                :origin,
                :effective_start_date,
                :effective_end_date,
                :import,
                :vat,
                :excise,
                :goods_nomenclature_item_id,
                :meursing,
                :resolved_duty_expression

  DEFAULT_GEOGRAPHICAL_AREA_ID = '1011'.freeze # ERGA OMNES

  has_one :geographical_area
  has_many :legal_acts
  has_one :measure_type
  has_one :suspension_legal_act, class_name: 'LegalAct'
  has_one :additional_code
  has_one :order_number
  has_one :duty_expression
  has_many :excluded_countries, class_name: 'GeographicalArea'
  has_many :measure_conditions
  has_many :footnotes
  has_one :goods_nomenclature

  def relevant_for_country?(country_code)
    return false if excluded_countries.map(&:geographical_area_id).include?(country_code)
    return true if geographical_area.id == DEFAULT_GEOGRAPHICAL_AREA_ID && national?
    return true if country_code.blank? || geographical_area.id == country_code

    geographical_area.children_geographical_areas.map(&:id).include?(country_code)
  end

  def excluded_country_list
    excluded_countries.map(&:description).join(', ').html_safe
  end

  def national?
    origin == 'uk'
  end

  def vat?
    vat
  end

  def vat_excise?
    declarable_types[:vat_and_excise].include?(measure_type.id)
  end

  def import_controls?
    declarable_types[:import_controls].include?(measure_type.id)
  end

  def trade_remedies?
    declarable_types[:remedies].include?(measure_type.id)
  end

  def customs_duties?
    declarable_types[:customs_duties].include?(measure_type.id)
  end

  def quotas?
    declarable_types[:quotas].include?(measure_type.id)
  end

  def third_country?
    measure_type.id == '103'
  end

  def tariff_preference?
    measure_type.id == '142'
  end

  def meursing?
    # MEURSING_IDS.in? duty_expression.to_s
  end

  def supplementary?
    options = %w[109 110 111]
    options.include?(measure_type.id)
  end

  def import?
    import
  end

  def export?
    !import
  end

  def destination
    import? ? 'import' : 'export'
  end

  def effective_start_date=(date)
    @effective_start_date = Date.parse(date) if date.present?
  end

  def effective_end_date=(date)
    @effective_end_date = Date.parse(date) if date.present?
  end

  def additional_code
    @additional_code.presence || NullObject.new(code: '')
  end

  def key
    "#{vat? ? 0 : 1}
     #{third_country? ? 0 : 1}
     #{supplementary? ? 0 : 1}
     #{excise ? 0 : 1}
     #{geographical_area.children_geographical_areas.any? ? 0 : 1}
     #{tariff_preference? ? 0 : 1}
     #{geographical_area.description}#{additional_code_sort}"
  end

  # _999 is the master additional code and should come first
  def additional_code_sort
    if additional_code && additional_code.code.to_s.include?('999')
      'A000'
    else
      additional_code.code.to_s
    end
  end

  private

  def declarable_types
    @declarable_types ||= Rails.configuration.declarable_types
  end
end
