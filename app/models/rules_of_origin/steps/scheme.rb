module RulesOfOrigin
  module Steps
    class Scheme < Base
      attribute :scheme_code

      validates :scheme_code, inclusion: { in: :available_scheme_codes }

      def available_scheme_codes
        rules_of_origin_schemes.map(&:scheme_code)
      end

      def skipped?
        rules_of_origin_schemes.one?
      end
    end
  end
end
