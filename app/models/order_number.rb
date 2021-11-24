class OrderNumber
  include ApiEntity

  attr_accessor :number

  delegate :present?, to: :number

  has_one :definition
  has_one :geographical_area
  has_many :geographical_areas

  def id
    @id ||= "#{casted_by.id}-order-number-#{number}"
  end

  def definition
    return @definition if @definition
    return casted_by if casted_by.is_a?(OrderNumber::Definition)
  end
end
