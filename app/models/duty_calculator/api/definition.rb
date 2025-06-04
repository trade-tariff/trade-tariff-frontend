module DutyCalculator
  module Api
    class Definition < Api::Base
      attributes :id,
                 :initial_volume,
                 :validity_start_date,
                 :validity_end_date,
                 :status,
                 :description,
                 :balance,
                 :measurement_unit,
                 :monetary_unit,
                 :measurement_unit_qualifier,
                 :last_allocation_date,
                 :suspension_period_start_date,
                 :suspension_period_end_date,
                 :blocking_period_start_date,
                 :blocking_period_end_date
    end
  end
end
