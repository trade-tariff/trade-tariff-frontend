module MeursingLookup
  module Steps
    class AnswerStep < WizardSteps::Step
      delegate :answer_for, to: :@wizard

      def self.inherited(child_class)
        child_class.attribute child_class.key, :string
        child_class.validates child_class.key, presence: true

        super
      end

      def current_tree
        raise NotImplementedError, 'See concrete implementation for the current_tree'
      end

      def options
        current_tree.each_key.map do |key|
          OpenStruct.new(id: key, name: key)
        end
      end

      def reviewable_answers
        {
          key => public_send(key),
        }
      end

      private

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

      def tree
        TradeTariffFrontend.meursing_code_tree
      end
    end
  end
end
