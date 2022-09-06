module RulesOfOrigin
  class SidebarSection
    attr_reader :name

    def initialize(wizard, name, steps = nil)
      @wizard = wizard
      @name = name
      @steps = steps.index_by(&:key)
    end

    def steps
      @steps.values
    end

    def current?
      @steps.keys.include? @wizard.current_key
    end
  end
end
