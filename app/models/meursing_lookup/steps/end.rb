module MeursingLookup
  module Steps
    class End < Base
      def meursing_code
        tree.dig(*answers)
      end

      def skipped?
        false
      end

      private

      def answers
        @wizard.answers_by_step.values.flat_map(&:values)
      end
    end
  end
end
