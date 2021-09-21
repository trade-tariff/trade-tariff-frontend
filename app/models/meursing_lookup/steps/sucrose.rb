module MeursingLookup
  module Steps
    class Sucrose < AnswerStep
      def current_tree
        tree[starch_answer]
      end
    end
  end
end
