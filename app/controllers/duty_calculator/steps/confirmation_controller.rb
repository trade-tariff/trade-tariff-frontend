module DutyCalculator
  module Steps
    class ConfirmationController < BaseController
      def show
        @step = Steps::Confirmation.new

        @decorated_step = ConfirmationDecorator.new(@step)
      end
    end
  end
end
