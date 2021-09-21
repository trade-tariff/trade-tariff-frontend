module MeursingLookup
  module Steps
    module Tree
      extend ActiveSupport::Concern

      class_methods do
        def tree
          @tree ||= begin
            filename = Rails.root.join('db/meursing_code_tree.json')
            JSON.parse(File.read(filename))
          end
        end
      end

      delegate :tree, to: :class
      delegate :answer_for, to: :@wizard

      def options
        current_tree.each_key.map do |key|
          OpenStruct.new(id: key, name: key)
        end
      end

      def current_tree
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
