module MeursingLookup
  module Steps
    class MilkProtein < AnswerStep
      def current_meursing_code_level
        meursing_codes.dig(starch_answer, sucrose_answer, milk_fat_answer)
      end

      # WizardSteps callback which decides whether this step should be rendered as the next step
      def skipped?
        # 'milk_protein_skipped' indicates this category does not require an answer and so this step will be skipped
        current_meursing_code_level.present? && current_meursing_code_level['milk_protein_skipped'].present?
      end
    end
  end
end
