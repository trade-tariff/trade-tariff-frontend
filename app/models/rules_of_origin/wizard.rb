module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::ImportExport,
      Steps::End,
    ]
  end
end
