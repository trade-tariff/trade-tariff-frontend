module RulesOfOrigin
  module Steps
    class DirectTransportRule < Base
      self.section = 'proofs'

      def skipped?
        true
      end

      def direct_transport_text
        chosen_scheme.article('direct-transport')&.content
      end
    end
  end
end
