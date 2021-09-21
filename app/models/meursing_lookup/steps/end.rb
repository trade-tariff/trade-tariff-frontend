module MeursingLookup
  module Steps
    class End < WizardSteps::Step
      include MeursingLookup::Steps::Tree

      def meursing_code
        meursing_code_without_milk_protein || default_meursing_code
      end

      private

      def default_meursing_code
        meursing_codes.dig(
          starch_answer,
          sucrose_answer,
          milk_fat_answer,
          milk_protein_answer,
        )
      end

      # 'milk_protein_skipped' keys mean the next meursing_codes level is skipped and we do not have answers for it so just retreive the 'milk_protein_skipped' key value which is a valid meursing code
      def meursing_code_without_milk_protein
        meursing_codes.dig(
          starch_answer,
          sucrose_answer,
          milk_fat_answer,
          'milk_protein_skipped',
        )
      end
    end
  end
end
