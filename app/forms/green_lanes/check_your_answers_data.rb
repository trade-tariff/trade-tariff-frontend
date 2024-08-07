module GreenLanes
  class CheckYourAnswersData
    include ActiveModel::Model

    attr_accessor :commodity_code_data,
                  :eligibility_data,
                  :moving_requirements_data,
                  :exemptions_answers_data

    def initialize(attributes = {})
      super
      @commodity_code_data ||= {}
      @eligibility_data ||= {}
      @moving_requirements_data ||= {}
      @exemptions_answers_data ||= {}
    end

    def attributes
      {
        commodity_code_data: @commodity_code_data,
        eligibility_data: @eligibility_data,
        moving_requirements_data: @moving_requirements_data,
        exemptions_answers_data: @exemptions_answers_data,
      }
    end
  end
end
