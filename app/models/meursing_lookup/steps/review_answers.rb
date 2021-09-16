module MeursingLookup
  module Steps
    class ReviewAnswers < WizardSteps::Step
      def answers_by_step
        @answers_by_step ||= @wizard.reviewable_answers_by_step.except(self.class)
      end
    end
  end
end
