module RulesOfOrigin
  module Steps
    class ProofRequirements < Base
      self.section = 'proofs'

      def skipped?
        @store['wholly_obtained'] == 'no'
      end

      def processes_text
        chosen_scheme.article('origin_processes')&.content
      end

      def processes_sections
        @processes_sections ||= \
          processes_text.split(/^(## )/m)
                        .map(&:presence)
                        .compact
                        .slice_before('## ')
                        .select { |marker, _| marker == '## ' }
                        .map(&:join)
      end

      def processes_section(section_number)
        section_number = section_number.to_i - 1
        processes_sections[section_number.positive? ? section_number : 0]
      end

      def processes_section_titles
        processes_sections.map do |content|
          content.lines(chomp: true).first.sub(/^## /, '')
        end
      end
    end
  end
end
