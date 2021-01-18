require 'api_entity'

class DutyExpression
  include ApiEntity

  attr_accessor :base, :formatted_base

  def to_s
    if formatted_base.present?
      formatted_base
    else
      base
    end
  end

  def amount
    base.delete('%').to_i
  end
end
