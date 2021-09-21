module MeursingLookup
  module Steps
    class Starch < AnswerStep
      alias_method :current_tree, :tree
    end
  end
end
