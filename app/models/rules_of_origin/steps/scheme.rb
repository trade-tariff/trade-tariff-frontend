module RulesOfOrigin
  module Steps
    class Scheme < Base
      attribute :scheme_code

      validates :scheme_code, inclusion: { in: :scheme_codes }

      def scheme_codes
        @store['scheme_codes'] || persist_scheme_codes
      end

      def skipped?
        scheme_codes.one?
      end

    private

      def persist_scheme_codes
        @store.persist(scheme_codes: rules_of_origin_schemes.map(&:scheme_code))

        @store['scheme_codes']
      end
    end
  end
end
