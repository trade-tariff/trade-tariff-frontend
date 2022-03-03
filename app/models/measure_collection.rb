class MeasureCollection
  include Enumerable

  attr_accessor :measures

  delegate :present?, to: :measures
  delegate :size, :length, :collect, :map, :each, :all?, :include?, :to_ary, to: :to_a

  def initialize(measures)
    @measures = measures.clone
  end

  def without_supplementary_unit
    self.class.new(measures.reject(&:supplementary?))
  end

  def for_country(country)
    self.class.new(measures.select { |m| m.relevant_for_country?(country) })
  end

  def vat_excise
    self.class.new(measures.select(&:vat_excise?))
  end

  def import_controls
    self.class.new(measures.select(&:import_controls?))
  end

  def trade_remedies
    self.class.new(measures.select(&:trade_remedies?))
  end

  def customs_duties
    self.class.new(measures.select(&:customs_duties?))
  end

  def quotas
    self.class.new(measures.select(&:quotas?))
  end

  def vat
    self.class.new(measures.select(&:vat?))
  end

  def national
    self.class.new(measures.select(&:national?))
  end

  def third_country_duty
    self.class.new(measures.select(&:third_country?))
  end

  def supplementary
    self.class.new(measures.select(&:supplementary?))
  end

  def to_a
    measures.map { |entry| MeasurePresenter.new(entry) }
  end
end
