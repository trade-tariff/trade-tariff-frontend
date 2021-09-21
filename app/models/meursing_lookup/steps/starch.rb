module MeursingLookup
  module Steps
    class Starch < AnswerStep
      alias_method :current_meursing_code_level, :meursing_codes
    end
  end
end
