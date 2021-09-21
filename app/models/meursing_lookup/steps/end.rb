module MeursingLookup
  module Steps
    class End < AnswerStep
      def meursing_code
        return answer if answer.is_a?(String)

        missing_category_answer
      end

      def skipped?
        false
      end

      private

      def answer
        tree.dig(*answers)
      end

      def missing_category_answer
        # When the leaf of the tree is missing the milk_protein category of answer it comes back as { "null": <code> } to reflect that we've answered the users meursing question.
        answer['null']
      end

      def answers
        @wizard.answers_by_step.values.flat_map(&:values)
      end
    end
  end
end
