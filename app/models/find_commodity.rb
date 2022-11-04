class FindCommodity
  include ActiveModel::Model

  attr_accessor :q,
                :day,
                :month,
                :year,
                :resource_id

  validate :date_is_valid

  def initialize(...)
    super

    default_to_today
  end

  def performing_search?
    q.present?
  end

  def date
    Date.civil(year.to_i, month.to_i, day.to_i) if date_parts_are_valid?
  end

  def date=(date)
    @year = date.year
    @month = date.month
    @day = date.day
  end

private

  def date_is_valid
    unless date_parts_are_valid?
      errors.add :date, :invalid_date
    end
  end

  def date_parts_are_valid?
    Date.valid_civil? year.to_i, month.to_i, day.to_i
  end

  def default_to_today
    return unless day.blank? && month.blank? && year.blank?

    self.date = Time.zone.today
  end
end
