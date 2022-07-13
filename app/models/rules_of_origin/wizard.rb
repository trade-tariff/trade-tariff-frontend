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
      Steps::OriginRequirementsMet,
      Steps::NotWhollyObtained,
      Steps::PartsComponents,
      Steps::End,
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
