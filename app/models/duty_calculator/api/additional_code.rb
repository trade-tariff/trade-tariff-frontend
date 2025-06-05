module DutyCalculator
  module Api
    class AdditionalCode < Api::Base
      attributes :id,
                 :code,
                 :description,
                 :formatted_description

      enum :additional_code_type, {
        excise: %w[X],
      }

      def formatted_code
        return additional_code_id if excise?

        code
      end

      def additional_code_type
        code && code[0]
      end

      def additional_code_id
        code && code[1..]
      end
    end
  end
end
