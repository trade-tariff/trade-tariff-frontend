class DeclarableUnitService
  def initialize(uk_declarable, xi_declarable, country)
    @uk_declarable = uk_declarable
    @xi_declarable = xi_declarable
    @country = country
  end

  def call
    uk? ? uk_units : xi_units
  end

  private

  def uk_units
    uk_import_measures = uk_declarable.import_measures.excluding_channel_islands

    return uk_import_measures.supplementary.first&.measure_components&.first&.unit_for_classification if uk_import_measures.supplementary.any?

    unit_measures = picked_country? ? uk_import_measures.unit : uk_import_measures.unit.erga_omnes

    unit_measure_units = units_for(unit_measures)
    excise_measure_units = units_for(uk_import_measures.excise.erga_omnes)

    translated_units_for(unit_measure_units, excise_measure_units)
  end

  def xi_units
    xi_import_measures = xi_declarable.import_measures.excluding_channel_islands
    uk_excise_measures = uk_declarable.import_measures.excluding_channel_islands.excise.erga_omnes

    return xi_import_measures.supplementary.first&.measure_components&.first&.unit_for_classification if xi_import_measures.supplementary.any?

    unit_measures = picked_country? ? xi_import_measures.unit : xi_import_measures.unit.erga_omnes

    unit_measure_units = units_for(unit_measures)
    excise_measure_units = units_for(uk_excise_measures)

    translated_units_for(unit_measure_units, excise_measure_units)
  end

  def units_for(measures)
    return nil if measures.none?

    units = measures.each_with_object({}) do |measure, acc|
      measure.measure_components.each do |component|
        if component.measurement_unit.present?
          acc[component.measurement_unit.resource_id] = component.measurement_unit&.description.to_s.downcase
        end
      end
    end

    units.values.sort.uniq.join(', ')
  end

  def translated_units_for(unit_measure_units, excise_measure_units)
    return I18n.t('declarable.supplementary_unit_classifications.none') if unit_measure_units.blank? && excise_measure_units.blank?

    if unit_measure_units.present? && excise_measure_units.present?
      I18n.t('declarable.supplementary_unit_classifications.unit_and_excise', excise_measure_units:, unit_measure_units:)
    elsif unit_measure_units.present?
      I18n.t('declarable.supplementary_unit_classifications.unit', units: unit_measure_units)
    elsif excise_measure_units.present?
      I18n.t('declarable.supplementary_unit_classifications.excise', units: excise_measure_units)
    end
  end

  def picked_country?
    country.present?
  end

  delegate :uk?, to: TradeTariffFrontend::ServiceChooser
end
