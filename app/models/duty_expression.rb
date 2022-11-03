require 'api_entity'

class DutyExpression
  include ApiEntity

  attr_accessor :base, :formatted_base, :verbose_duty

  def to_s
    if verbose_duty.present?
      verbose_duty
    else
      base
    end
  end

  def amount
    base.delete('%').to_i
  end
end
