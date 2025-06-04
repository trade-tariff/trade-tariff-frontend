module DutyCalculator
  module Api
    class OrderNumber < Api::Base
      attributes :id,
                 :number,
                 :definition

      has_one :definition, Definition
    end
  end
end
