module DutyCalculator
  module Errors
    class SessionIntegrityError < StandardError
      def initialize(expected_attribute)
        super

        @expected_attribute = expected_attribute
      end

      def message
        "User session state error. You are missing #{@expected_attribute}. Do you have multiple tabs open?"
      end
    end
  end
end
