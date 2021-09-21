module MeursingLookup
  module Steps
    class End < WizardSteps::Step
      include MeursingLookup::Steps::Tree

      def meursing_code
        missing_milk_protein_meursing_code || tree.dig(starch_answer, sucrose_answer, milk_fat_answer, milk_protein_answer)
      end

      private

      # 'skip_milk_protein' keys mean the next tree level is skipped and we do not have answers for it so just retreive the 'skip_milk_protein' key value which is a valid meursing code
      def missing_milk_protein_meursing_code
        tree.dig(starch_answer, sucrose_answer, milk_fat_answer, 'skip_milk_protein').presence
      end
    end
  end
end
