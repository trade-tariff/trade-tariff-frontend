module Declarable
  extend ActiveSupport::Concern

  included do
    include ApiEntity

    has_one :section
    has_one :chapter
    has_one :import_trade_summary
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
                  :has_chemicals,
                  :meta

    meta_attribute :duty_calculator, :zero_mfn_duty

    alias_method :declarable?, :declarable
    alias_method :has_chemicals?, :has_chemicals
    alias_method :zero_mfn_duty?, :zero_mfn_duty

    delegate :numeral, to: :section, prefix: true
    delegate :code, :short_code, to: :chapter, prefix: true
  end

  def has_export_measures?
    export_measures&.any?
  end

  def has_pharma_suspsension_measures?
    import_measures.third_country_duties.any?(&:pharma_additional_code?)
  end

  def one_or_more_prohibitive_measures?
    import_measures.any?(&:prohibitive?)
  end

  def one_or_more_conditionally_prohibitive_measures?
    import_measures.any?(&:conditionally_prohibitive?)
  end

  def calculate_duties?
    no_heading? && no_entry_price_system?
  end

  def critical_footnotes
    @critical_footnotes = footnotes.select(&:critical_warning?)
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

  def display_export_code
    code_without_taric_subheading = code[0..-3]
    "#{code_without_taric_subheading[0..3]} #{code_without_taric_subheading[4..]}"
  end

  def all_footnotes
    (
      footnotes +
      export_measures.map(&:footnotes).select(&:present?).flatten +
      import_measures.map(&:footnotes).select(&:present?).flatten
    ).uniq(&:code)
  end

  def supplementary_unit_description
    import_measures.supplementary.first&.supplementary_unit_description || 'Supplementary unit'
  end

  # Right-Strip of the zeros in pairs.
  # Example: 8514101000 -> 85141010
  def commodity_code_for_check_duties_service
    code.gsub(/(00|0000)$/, '')
  end

  def has_safeguard_measure?
    import_measures.any?(&:safeguard?)
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
