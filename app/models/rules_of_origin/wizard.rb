module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::Start,
      Steps::ImportExport,
      Steps::Originating,
      Steps::End,
    ]
  end
end
