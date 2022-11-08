module RulesOfOrigin
  module Steps
    class RulesNotMet < Base
      self.section = 'originating'

      def skipped?
        if only_wholly_obtained_rules?
          wholly_obtained?
        else
          skipped_for_multiple_rules?
        end
      end

      def first_step
        @wizard.next_key('start')
      end

      def tolerances_text
        chosen_scheme.article('tolerances')&.content
      end

      def show_cumulation_section?
        !@wizard.find('cumulation').skipped?
      end

    private

      def skipped_for_multiple_rules?
        wholly_obtained? || sufficiently_processed? && meets_rules?
      end

      def wholly_obtained?
        @store['wholly_obtained'] == 'yes'
      end

      def sufficiently_processed?
        @store['sufficient_processing'] == 'yes'
      end

      def meets_rules?
        @store['rule'].present? && @store['rule'] != 'none'
      end
    end
  end
end
