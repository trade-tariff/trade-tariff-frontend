module DutyCalculator
  module Steps
    class ConfirmationController < BaseController
      def show
        @step = Steps::Confirmation.new
        user_session.return_to_confirm = true

        @decorated_step = ConfirmationDecorator.new(@step)
      end
    end
  end
end
