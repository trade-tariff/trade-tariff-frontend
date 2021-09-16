module MeursingLookup
  module Steps
    class Base < WizardSteps::Step
      def self.inherited(child_class)
        child_class.attribute child_class.key, :string
        child_class.validates child_class.key, presence: true

        super
      end

      def options
        [
          OpenStruct.new(id: '0 - 4.99', name: '0 - 4.99'),
          OpenStruct.new(id: '5 - 24.99', name: '5 - 24.99'),
          OpenStruct.new(id: '25 - 49.99', name: '25 - 49.99'),
          OpenStruct.new(id: '50 - 74.99', name: '50 - 74.99'),
          OpenStruct.new(id: '75 or more', name: '75 or more'),
        ]
      end

      def reviewable_answers
        {
          key => public_send(key),
        }
      end
    end
  end
end
