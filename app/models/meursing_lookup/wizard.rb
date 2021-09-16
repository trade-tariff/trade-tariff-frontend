module MeursingLookup
  class Wizard < WizardSteps::Base
    self.steps = [
      MeursingLookup::Steps::Starch,
      MeursingLookup::Steps::Sucrose,
      MeursingLookup::Steps::MilkFat,
      MeursingLookup::Steps::MilkProtein,
      MeursingLookup::Steps::ReviewAnswers,
    ]

    def self.step_level(key)
      steps.index { |step| step.key == key }
    end
  end
end
