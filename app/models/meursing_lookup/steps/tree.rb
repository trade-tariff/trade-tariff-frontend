module MeursingLookup
  module Steps
    module Tree
      extend ActiveSupport::Concern

      included do
        delegate :meursing_codes, to: :class
        delegate :answer_for, to: :@wizard
      end

      class_methods do
        def meursing_codes
          @meursing_codes ||= begin
            filename = Rails.root.join('db/meursing_code_tree.json')
            JSON.parse(File.read(filename))
          end
        end
      end

      def options
        current_meursing_code_level.each_key.map do |key|
          OpenStruct.new(id: key, name: key)
        end
      end

      def current_meursing_code_level
        raise NotImplementedError, 'Implement this where this module is included'
      end

      def starch_answer
        answer_for(Starch)
      end

      def sucrose_answer
        answer_for(Sucrose)
      end

      def milk_fat_answer
        answer_for(MilkFat)
      end

      def milk_protein_answer
        answer_for(MilkProtein)
      end
    end
  end
end
