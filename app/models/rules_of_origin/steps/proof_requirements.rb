module RulesOfOrigin
  module Steps
    class ProofRequirements < Base
      self.section = 'proofs'

      def skipped?
        true
      end

      def processes_text
        origin_processes&.content
      end

      def processes_sections
        origin_processes&.sections || []
      end

      def processes_section(section_number)
        origin_processes&.section(section_number)
      end

      def processes_section_titles
        origin_processes&.subheadings || []
      end

    private

      def origin_processes
        chosen_scheme.article('origin_processes')
      end
    end
  end
end
