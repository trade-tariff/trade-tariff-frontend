module RulesOfOrigin
  module Steps
    class WhollyObtained < Base
      OPTIONS = %w[yes no].freeze

      self.section = 'originating'

      attribute :wholly_obtained

      validates :wholly_obtained, presence: true,
                                  inclusion: { in: OPTIONS }

      def scheme_title
        chosen_scheme.title
      end
    end
  end
end
