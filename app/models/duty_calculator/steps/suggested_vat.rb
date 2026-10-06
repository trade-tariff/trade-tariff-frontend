module DutyCalculator
  module Steps
    # Shown after the trader answers "I don't know" on the VAT page.
    class SuggestedVat < Steps::Base
      def next_step_path
        confirm_path
      end

      def previous_step_path
        vat_path
      end
    end
  end
end
