module MeursingLookup
  module Steps
    class MilkFat < AnswerStep
      def current_tree
        tree.dig(starch_answer, sucrose_answer)
      end
    end
  end
end
