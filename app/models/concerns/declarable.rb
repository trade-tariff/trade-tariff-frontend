module Declarable
  extend ActiveSupport::Concern

  included do
    include ApiEntity

    has_one :section
    has_one :chapter
    has_many :footnotes
    has_many :import_measures, class_name: 'Measure',
                               wrapper: MeasureCollection,
                               filter: :without_excluded,
                               presenter: MeasurePresenter
    has_many :export_measures, class_name: 'Measure',
                               wrapper: MeasureCollection,
                               filter: :without_excluded,
                               presenter: MeasurePresenter

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

  def supplementary_unit_description(country:)
    supplementary_measure(country)&.supplementary_unit_description || 'Supplementary unit'
  end

  def supplementary_unit(country:)
    measure = supplementary_measure(country)
    supplementary_component = measure&.measure_components&.first

    if supplementary_component
      "#{supplementary_component.measurement_unit&.description} (#{measure.duty_expression&.base})"
    else
      'No supplementary unit required.'
    end
  end

  # Right-Strip of the zeros in pairs.
  # Example: 8514101000 -> 85141010
  def commodity_code_for_check_duties_service
    code.gsub(/(00|0000)$/, '')
  end

  private

  def supplementary_measure(country)
    supplementary_measures(country).first
  end

  def supplementary_measures(country)
    @supplementary_measures ||= import_measures.for_country(country).supplementary
  end

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
