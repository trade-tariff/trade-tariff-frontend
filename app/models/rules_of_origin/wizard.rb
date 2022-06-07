module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::ImportExport,
      Steps::Originating,
      Steps::End,
    ]
  end
end
