class MeasureCollection
  include Enumerable

  attr_accessor :measures, :presenter_klass

  delegate :size, :length, :collect, :map, :each, :all?, :include?, :to_ary, to: :to_a

  def initialize(measures, presenter_klass = MeasurePresenter)
    @measures = measures.clone
    @presenter_klass = presenter_klass
  end

  def for_country(country)
    self.measures = measures.select { |m| m.relevant_for_country?(country) }
    self
  end

  def vat_excise
    @vat_excise ||= begin
      self.measures = measures.select(&:vat_excise?)
      self
    end
  end

  def import_controls
    @import_controls ||= begin
      self.measures = measures.select(&:import_controls?)
      self
    end
  end

  def trade_remedies
    @trade_remedies ||= begin
      self.measures = measures.select(&:trade_remedies?)
      self
    end
  end

  def customs_duties
    @customs_duties ||= begin
      self.measures = measures.select(&:customs_duties?)
      self
    end
  end

  def quotas
    @quotas ||= begin
      self.measures = measures.select(&:quotas?)
      self
    end
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
    if presenter_klass.present?
      present_with(presenter_klass)
    else
      measures
    end
  end

  def present?
    measures.any?
  end

  private

  def present_with(presenter_klass)
    measures.map { |entry| presenter_klass.new(entry) }
  end
end
