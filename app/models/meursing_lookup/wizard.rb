module MeursingLookup
  class Wizard < WizardSteps::Base
    self.steps = [
      MeursingLookup::Steps::Starch,
      MeursingLookup::Steps::Sucrose,
      MeursingLookup::Steps::MilkFat,
      MeursingLookup::Steps::MilkProtein,
      MeursingLookup::Steps::ReviewAnswers,
      MeursingLookup::Steps::End,
    ]

    def self.step_level(key)
      steps.index { |step| step.key == key }
    end

    def answers_by_step
      @answers_by_step ||= reviewable_answers_by_step.except(
        MeursingLookup::Steps::ReviewAnswers,
        MeursingLookup::Steps::End,
      )
    end
  end
end
