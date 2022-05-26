module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::Start,
      Steps::End,
    ]
  end
end
