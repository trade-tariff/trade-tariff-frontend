module DutyCalculator
  module Api
    module RulesOfOrigin
      class Proof < Api::Base
        attributes :summary,
                   :subtext,
                   :url
      end
    end
  end
end
