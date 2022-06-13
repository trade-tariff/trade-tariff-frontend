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

    class << self
      def grouped_steps
        @grouped_steps ||= steps.select(&:section).group_by(&:section)
      end

      def sections
        grouped_steps.keys
      end
    end

    def rules_of_origin_schemes
      @rules_of_origin_schemes ||=
        RulesOfOrigin::Scheme.all(@store['commodity_code'],
                                  @store['country_code'])
    end
  end
end
