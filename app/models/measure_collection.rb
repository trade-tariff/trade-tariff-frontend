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

  def for_country(country)
    new(select { |m| m.relevant_for_country?(country) })
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

  def vat
    new(select(&:vat?))
  end

  def national
    new(select(&:national?))
  end

  def supplementary
    new(select(&:supplementary?))
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
