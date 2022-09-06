module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::Start,
      Steps::Scheme,
      Steps::ImportExport,
      Steps::ImportOnly,
      Steps::Originating,
      Steps::WhollyObtainedDefinition,
      Steps::ComponentsDefinition,
      Steps::WhollyObtained,
      Steps::NotWhollyObtained,
      Steps::Cumulation,
      Steps::SufficientProcessing,
      Steps::Subdivisions,
      Steps::ProductSpecificRules,
      Steps::OriginRequirementsMet,
      Steps::ProofsOfOrigin,
      Steps::ProofRequirements,
      Steps::ProofVerification,
      Steps::RulesNotMet,
    ]

    def sections
      @sections ||= steps.select(&:section)
                         .group_by(&:section)
                         .map { |name, steps| SidebarSection.new(self, name, steps) }
    end

    def rules_of_origin_schemes
      @rules_of_origin_schemes ||=
        RulesOfOrigin::Scheme.all(@store['commodity_code'],
                                  @store['country_code'])
    end
  end
end
