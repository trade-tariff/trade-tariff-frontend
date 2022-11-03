require 'api_entity'

class DutyExpression
  include ApiEntity

  attr_accessor :base, :formatted_base, :verbose_duty

  def to_s
    verbose_duty.presence || base
  end

  def amount
    base.delete('%').to_i
  end
end
