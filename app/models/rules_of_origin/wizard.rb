module RulesOfOrigin
  class Wizard < ::WizardSteps::Base
    self.steps = [
      Steps::Start,
      Steps::Scheme,
      Steps::ImportExport,
      Steps::ImportOnly,
      Steps::Originating,
      Steps::End,
    ]

    def sections
      @sections ||= steps.select(&:section)
                         .group_by(&:section)
                         .map(&method(:build_section))
    end

    def rules_of_origin_schemes
      @rules_of_origin_schemes ||=
        RulesOfOrigin::Scheme.all(@store['commodity_code'],
                                  @store['country_code'])
    end

  private

    def build_section(name, steps)
      SidebarSection.new(self, name, steps)
    end
  end
end
