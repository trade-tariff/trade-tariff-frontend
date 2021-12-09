class ImportExportDate
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :import_date, :tariff_date

  delegate :day, :month, :year, to: :import_date, allow_nil: true

  validate :import_date_valid

  private

  def import_date_valid
    errors.add(:import_date, :invalid_date) unless attributes.empty? || import_date.is_a?(Date)
  end
end
