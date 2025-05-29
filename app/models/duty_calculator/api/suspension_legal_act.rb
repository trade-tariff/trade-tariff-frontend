module DutyCalculator
  module Api
    class SuspensionLegalAct < Api::Base
      attributes :id,
                 :validity_end_date,
                 :validity_start_date,
                 :regulation_code,
                 :regulation_url
    end
  end
end
