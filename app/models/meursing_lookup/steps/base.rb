module MeursingLookup
  module Steps
    class Base < WizardSteps::Step
      def self.inherited(child_class)
        child_class.attribute child_class.key, :string
        child_class.validates child_class.key, presence: true

        super
      end

      def options
        @options ||= begin
          current_tree = tree

          previous_answers.each.with_index do |answer, index|
            if index >= previous_answers.size - 1
              return current_tree[answer].each_key.map { |key| option_for(key) }
            end

            current_tree = current_tree[answer].presence || current_tree['null']

            next if current_tree.is_a?(Hash)

            return current_tree
          end
        end

        base_keys
      end

      def skipped?
        options.first && options.first.id == 'null'
      end

      def reviewable_answers
        {
          key => public_send(key),
        }
      end

      private

      def base_keys
        tree.each_key.map { |key| option_for(key) }
      end

      def tree
        TradeTariffFrontend.meursing_code_tree
      end

      def previous_answers
        @previous_answers ||= @wizard.earlier_keys(key).map do |key|
          @store[key]
        end
      end

      def option_for(key)
        OpenStruct.new(id: key, name: key)
      end
    end
  end
end
