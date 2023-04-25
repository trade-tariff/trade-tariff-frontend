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

  def supplementary_unit
    if supplementary_component.present?
      supplementary_component.unit_for_classification
    elsif supplementary_excise_measures?
      excise_unit_for_classification
    else
      no_supplementary_unit_classification
    end
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

  def supplementary_component
    @supplementary_component ||= import_measures.supplementary.first&.measure_components&.first
  end

  def supplementary_excise_measures?
    import_measures.excise.erga_omnes.any?(&:measurement_units?)
  end

  def excise_unit_for_classification
    excise_units = import_measures.excise.erga_omnes.each_with_object({}) do |measure, acc|
      measure.measure_components.each do |component|
        if component.measurement_unit.present?
          acc[component.measurement_unit.resource_id] = component.measurement_unit&.description.to_s.downcase
        end
      end
    end

    excise_units = excise_units.values.sort.uniq.join(', ')

    I18n.t('declarable.supplementary_unit_classifications.excise', units: excise_units)
  end

  def no_supplementary_unit_classification
    I18n.t('declarable.supplementary_unit_classifications.none')
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
