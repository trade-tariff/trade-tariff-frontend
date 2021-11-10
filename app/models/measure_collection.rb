class MeasureCollection
  include Enumerable

  attr_accessor :measures

  delegate :present?, to: :measures
  delegate :size, :length, :collect, :map, :each, :all?, :include?, :to_ary, to: :to_a

  def initialize(measures)
    @measures = measures.clone
  end

  def for_country(country)
    self.measures = measures.select { |m| m.relevant_for_country?(country) }
    self
  end

  def vat_excise
    self.measures = measures.select(&:vat_excise?)
    self
  end

  def import_controls
    self.measures = measures.select(&:import_controls?)
    self
  end

  def trade_remedies
    self.measures = measures.select(&:trade_remedies?)
    self
  end

  def customs_duties
    self.measures = measures.select(&:customs_duties?)
    self
  end

  def quotas
    self.measures = measures.select(&:quotas?)
    self
  end

  def vat
    self.measures = measures.select(&:vat?)
    self
  end

  def national
    self.measures = measures.select(&:national?)
    self
  end

  def third_country_duty
    self.measures = measures.select(&:third_country?)
    self
  end

  def supplementary
    self.measures = measures.select(&:supplementary?)
    self
  end

  def to_a
    measures.map { |entry| MeasurePresenter.new(entry) }
  end
end
