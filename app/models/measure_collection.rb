class MeasureCollection
  include Enumerable

  attr_accessor :measures

  delegate :+, :present?, :size, :length, :collect, :map, :each, :all?, :include?, to: :to_a
  delegate :new, to: :class

  def initialize(measures)
    @measures = measures.clone.presence || []
  end

  def without_supplementary_unit
    new(measures.reject(&:supplementary?))
  end

  def without_excluded
    new(measures.reject(&:excluded?))
  end

  def for_country(country)
    new(measures.select { |m| m.relevant_for_country?(country) })
  end

  def vat_excise
    new(measures.select(&:vat_excise?))
  end

  def import_controls
    new(measures.select(&:import_controls?) + measures.select(&:unclassified_import_controls?))
  end

  def customs_duties
    new(third_country_duties + tariff_preferences + other_customs_duties + unclassified_customs_duties)
  end

  def trade_remedies
    new(measures.select(&:trade_remedies?))
  end

  def quotas
    new(measures.select(&:quotas?))
  end

  def third_country_duties
    new(measures.select(&:third_country_duties?))
  end

  def vat
    new(measures.select(&:vat?))
  end

  def national
    new(measures.select(&:national?))
  end

  def supplementary
    new(measures.select(&:supplementary?))
  end

  def to_a
    measures.map { |entry| MeasurePresenter.new(entry) }
  end

  private

  def tariff_preferences
    measures.select(&:tariff_preferences?)
  end

  def other_customs_duties
    measures.select(&:other_customs_duties?)
  end

  def unclassified_customs_duties
    measures.select(&:unclassified_customs_duties?)
  end
end
