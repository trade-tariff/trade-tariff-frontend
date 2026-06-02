module DutyCalculator
  class Option < Data.define(:id, :name, :disabled)
    def initialize(id:, name:, disabled: false)
      super(id:, name:, disabled:)
    end
  end
end
