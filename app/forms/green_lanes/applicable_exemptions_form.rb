module GreenLanes
  class ApplicableExemptionsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    NO_ANSWER_WAS_GIVEN = [''].freeze
    NONE_ANSWER_WAS_GIVEN = ['', 'none'].freeze

    attr_reader :answers, :category_assessments

    validates_each :answers do |record, _attr, _value|
      record.category_assessments.each do |category_assessment, _all_answered|
        key = category_assessment.id
        value = record.public_send(key)

        record.errors.add(key, 'Select if any exemptions apply') if value == NO_ANSWER_WAS_GIVEN
      end
    end

    def initialize(attributes)
      @answers = attributes['answers']
      @category_assessments = attributes['category_assessments']
      @category_assessments.each do |category_assessment|
        key = category_assessment.id
        define_singleton_method(key) do
          instance_variable_get("@#{key}")
        end

        define_singleton_method("#{key}=") do |value|
          instance_variable_set("@#{key}", value)
        end
      end

      @answers.each do |key, value|
        public_send("#{key}=", value)
      end
    end

    def exempt?
      answers.values.none? { |value| value == NONE_ANSWER_WAS_GIVEN }
    end
  end
end
