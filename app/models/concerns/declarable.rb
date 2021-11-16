module Declarable
  extend ActiveSupport::Concern

  included do
    include ApiEntity

    has_one :section
    has_one :chapter
    has_many :footnotes
    has_many :import_measures, class_name: 'Measure',
                               wrapper: MeasureCollection
    has_many :export_measures, class_name: 'Measure',
                               wrapper: MeasureCollection

    attr_accessor :description,
                  :goods_nomenclature_item_id,
                  :number_indents,
                  :goods_nomenclature_sid,
                  :bti_url,
                  :description_plain,
                  :formatted_description,
                  :consigned,
                  :consigned_from,
                  :basic_duty_rate,
                  :meursing_code,
                  :producline_suffix,
                  :declarable,
                  :meta

    alias_method :declarable?, :declarable

    delegate :numeral, to: :section, prefix: true
    delegate :code, :short_code, to: :chapter, prefix: true
  end

  def calculate_duties?
    no_heading? && no_entry_price_system?
  end

  def meursing_code?
    meta&.dig('duty_calculator', 'meursing_code')
  end

  def heading?
    code && code.last(6) == Heading::HEADING_PATTERN
  end

  def code
    goods_nomenclature_item_id
  end

  def all_footnotes
    (
      footnotes +
      export_measures.map(&:footnotes).select(&:present?).flatten +
      import_measures.map(&:footnotes).select(&:present?).flatten
    ).uniq(&:code)
  end

  def supplementary_unit(country: nil)
    supplementary_measures = import_measures.for_country(country).supplementary

    case supplementary_measures.count
    when 0
      'No supplementary unit required.'
    when 1
      supplementary_measure = supplementary_measures.first
      supplementary_measure_component = supplementary_measure.measure_components.first

      "#{supplementary_measure_component.measurement_unit.description} (#{supplementary_measure.duty_expression.base})"
    else
      'There are multiple supplementary units for you trade. See measures below.'
    end
  end

  private

  def no_heading?
    !heading?
  end

  def no_entry_price_system?
    !entry_price_system?
  end

  def entry_price_system?
    meta&.dig('duty_calculator', 'entry_price_system')
  end
end
