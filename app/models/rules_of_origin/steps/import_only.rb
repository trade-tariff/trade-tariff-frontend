module RulesOfOrigin
  module Steps
    class ImportOnly < Base
      attribute :import_only, :boolean

      def skipped?
        !chosen_scheme.unilateral
      end
    end
  end
end
