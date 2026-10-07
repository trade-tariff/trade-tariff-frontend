module DutyCalculator
  module Steps
    class ConfirmationController < BaseController
      def show
        @step = Steps::Confirmation.new
        user_session.return_to_confirm = true if duty_calculator_ux_improvements?

        @decorated_step = ConfirmationDecorator.new(@step)
      end
    end
  end
end
