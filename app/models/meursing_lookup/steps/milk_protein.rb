module MeursingLookup
  module Steps
    class MilkProtein < AnswerStep
      def current_tree
        tree.dig(starch_answer, sucrose_answer, milk_fat_answer)
      end

      # WizardSteps callback which decides whether this step should be rendered as the next step
      def skipped?
        # 'null' indicates this category does not require an answer and so this step will be skipped
        current_tree.present? && current_tree['null'].present?
      end
    end
  end
end
