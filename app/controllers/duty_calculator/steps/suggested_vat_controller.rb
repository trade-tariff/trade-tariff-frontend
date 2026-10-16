module DutyCalculator
  module Steps
    class SuggestedVatController < BaseController
      def show
        return redirect_to vat_path unless user_session.vat_assumed && user_session.vat.present?

        @step = Steps::SuggestedVat.new
      end
    end
  end
end
