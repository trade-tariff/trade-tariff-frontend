class ChangeDate
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :import_date, :date

  def initialize(attributes = {})
    # We need to do validations before attribute coersion for multiparameter assignment
    # otherwise we get a MultiparameterAssignmentErrors error propagated when we fail to cast and do not attach the correct error messages for the form.
    valid_attributes?(attributes)

    super(attributes)
  end

  def day
    import_date&.day
  end

  def month
    import_date&.month
  end

  def year
    import_date&.year
  end

  private

  def valid_attributes?(attributes)
    return if attributes.empty? || valid_date?(attributes)

    errors.add(:import_date, :invalid_date)

    attributes.delete 'import_date(1i)'
    attributes.delete 'import_date(2i)'
    attributes.delete 'import_date(3i)'
  end

  def valid_date?(attributes)
    Date.civil(
      Integer(attributes['import_date(1i)']),
      Integer(attributes['import_date(2i)']),
      Integer(attributes['import_date(3i)']),
    )
  rescue ArgumentError
    false
  end
end
