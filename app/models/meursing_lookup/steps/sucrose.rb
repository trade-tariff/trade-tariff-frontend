module MeursingLookup
  module Steps
    class Sucrose < AnswerStep
      def current_meursing_code_level
        meursing_codes[starch_answer]
      end
    end
  end
end
