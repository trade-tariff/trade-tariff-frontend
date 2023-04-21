class MeasureCollection < SimpleDelegator
  delegate :new, to: :class

  attr_reader :measures

  def initialize(measures)
    @measures = measures.clone.presence || []

    super @measures
  end

  def without_supplementary_unit
    new(reject(&:supplementary?))
  end

  def without_excluded
    new(reject(&:excluded?))
  end

  def suspensions
    new(select(&:suspension?))
  end

  def credibility_checks
    new(select(&:credibility_check?))
  end

  def vat_excise
    new(select(&:vat_excise?))
  end

  def import_controls
    new(select(&:import_controls?) + select(&:unclassified_import_controls?))
  end

  def customs_duties
    new(third_country_duties + tariff_preferences + other_customs_duties + unclassified_customs_duties)
  end

  def trade_remedies
    new(select(&:trade_remedies?))
  end

  def quotas
    new(select(&:quotas?))
  end

  def third_country_duties
    new(select(&:third_country_duties?))
  end

  def unique_third_country_overview_measures
    if third_country_duties.many?
      new([third_country_duties.find(&:mfn_no_authorized_use?)])
    else
      third_country_duties
    end
  end

  def with_additional_code
    new(select { |measure| measure.additional_code.present? })
  end

  def erga_omnes
    new(select(&:erga_omnes?))
  end

  def vat
    new(select(&:vat?).sort_by(&:amount).reverse)
  end

  def vat_erga_omnes
    new(vat.select { |measure_collection| measure_collection.geographical_area.id == GeographicalArea::ERGA_OMNES_ID })
  end

  def measure_with_highest_vat_rate_erga_omnes
    vat_erga_omnes.max_by(&:amount)
  end

  def measure_with_highest_vat_rate
    vat.max_by(&:amount)
  end

  def excise
    new(select(&:excise?))
  end

  def excise?
    excise.any?
  end

  def national
    new(select(&:national?))
  end

  def supplementary
    new(select(&:supplementary?))
  end

  def find_by_quota_order_number(number)
    quotas.find { |m| m.order_number.number == number }
  end

  private

  def tariff_preferences
    select(&:tariff_preferences?)
  end

  def other_customs_duties
    select(&:other_customs_duties?)
  end

  def unclassified_customs_duties
    select(&:unclassified_customs_duties?)
  end
end
