class Change
  include ApiEntity
  extend  ActiveModel::Naming

  attr_accessor :oid, :model_name, :operation, :operation_date, :record

  def id
    [model_name, oid].join('-')
  end

  def record=(record_attributes)
    @record = model_name.constantize.new(record_attributes)
  end

  def operation_date=(operation_date)
    @operation_date = Date.parse(operation_date)
  end

  def change_url(_changeable)
    '/'
  end
end
