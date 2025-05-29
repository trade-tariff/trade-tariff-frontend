module DutyCalculator
  module Api
    class RulesOfOriginScheme < Api::Base
      has_many :rules, RulesOfOrigin::Rule
      has_many :links, RulesOfOrigin::Link
      has_many :proofs, RulesOfOrigin::Proof

      attributes :scheme_code,
                 :title,
                 :countries,
                 :footnote,
                 :fta_intro,
                 :introductory_notes,
                 :unilateral
    end
  end
end
