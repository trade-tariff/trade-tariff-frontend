module DutyCalculator
  module Api
    class DutyExpression < Api::Base
      attributes :id,
                 :base,
                 :formatted_base
    end
  end
end
