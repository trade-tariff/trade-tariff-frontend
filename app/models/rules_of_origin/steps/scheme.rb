module RulesOfOrigin
  module Steps
    class Scheme < Base
      attribute :scheme_code

      validates :scheme_code, inclusion: { in: :scheme_codes }

      def scheme_codes
        @scheme_codes ||= rules_of_origin_schemes.map(&:scheme_code)
      end
    end
  end
end
