module MeursingLookup
  module Steps
    class AnswerStep < WizardSteps::Step
      include MeursingLookup::Steps::Tree

      def self.inherited(child_class)
        child_class.attribute child_class.key, :string
        child_class.validates child_class.key, presence: true

        super
      end
    end
  end
end
