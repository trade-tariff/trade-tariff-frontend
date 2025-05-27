module DutyCalculator
  module Steps
    class TraderSchemeController < BaseController
      helper_method :title

      def show
        @step = Steps::TraderScheme.new
      end

      def create
        @step = Steps::TraderScheme.new(permitted_params)

        validate(@step)
      end

      def title
        t("page_titles.#{@step.class.try(:id)}", market_scheme_type:, default: super)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_trader_scheme).permit(
          :trader_scheme,
        )
      end
    end
  end
end
