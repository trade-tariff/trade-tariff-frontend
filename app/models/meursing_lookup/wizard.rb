module MeursingLookup
  class Wizard < WizardSteps::Base
    self.steps = [
      MeursingLookup::Steps::Start,
      MeursingLookup::Steps::Starch,
      MeursingLookup::Steps::Sucrose,
      MeursingLookup::Steps::MilkFat,
      MeursingLookup::Steps::MilkProtein,
      MeursingLookup::Steps::ReviewAnswers,
      MeursingLookup::Steps::End,
    ]

    def answers_by_step
      @answers_by_step ||= reviewable_answers_by_step.except(
        MeursingLookup::Steps::Start,
        MeursingLookup::Steps::ReviewAnswers,
        MeursingLookup::Steps::End,
      )
    end

    def answer_for(step)
      find(step.key).public_send(step.key)
    end
  end
end
