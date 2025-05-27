module Api
  module RulesOfOrigin
    class Rule < Api::Base
      attributes :heading,
                 :description,
                 :rule,
                 :alternate_rule
    end
  end
end
