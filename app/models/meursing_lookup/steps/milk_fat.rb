module MeursingLookup
  module Steps
    class MilkFat < AnswerStep
      def current_meursing_code_level
        meursing_codes.dig(starch_answer, sucrose_answer)
      end
    end
  end
end
