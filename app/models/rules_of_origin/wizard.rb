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
      Steps::DutyDrawback,
      Steps::NonAlterationRule,
      Steps::RulesNotMet,
      Steps::Tolerances,
    ]

    def sections
      @sections ||= steps_for_sections.map do |name, steps|
        SidebarSection.new(self, name, steps)
      end
    end

    def rules_of_origin_schemes
      @rules_of_origin_schemes ||=
        RulesOfOrigin::Scheme.all(@store['commodity_code'],
                                  @store['country_code'])
    end

  private

    def steps_for_sections
      current_and_earlier_steps.select(&:section).group_by(&:section)
    end

    def current_and_earlier_steps
      earlier_steps << find_current_step
    end

    def earlier_steps
      earlier_keys.map(&method(:find))
                  .reject(&:skipped?)
    end
  end
end
