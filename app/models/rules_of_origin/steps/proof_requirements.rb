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

      def processes_section(section_number)
        origin_processes&.section(section_number)
      end

      def processes_contents_list
        origin_processes&.sections_contents_list || {}
      end

    private

      def origin_processes
        chosen_scheme.article('origin_processes')
      end
    end
  end
end
