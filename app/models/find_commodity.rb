class FindCommodity
  include ActiveModel::Model

  attr_accessor :q,
                :day,
                :month,
                :year,
                :resource_id,
                :commit

  validate :date_is_valid
  validates :q, presence:{message: :blank_search}, allow_nil: true

  def initialize(...)
    super

    default_to_today
  end

  def date
    Date.civil(year.to_i, month.to_i, day.to_i) if Date.valid_civil? year.to_i, month.to_i, day.to_i
  end

  def date=(date)
    @year = date.year
    @month = date.month
    @day = date.day
  end

private

  def date_is_valid
    unless Date.valid_civil? year.to_i, month.to_i, day.to_i
      errors.add :date, :invalid_date
    end
  end

  def default_to_today
    return unless day.blank? && month.blank? && year.blank?

    self.date = Time.zone.today
  end
end
