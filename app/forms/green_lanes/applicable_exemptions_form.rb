module GreenLanes
  class ApplicableExemptionsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    NO_ANSWER_WAS_GIVEN = [''].freeze
    NONE_ANSWER_WAS_GIVEN = 'none'.freeze

    attr_reader :answers, :category_assessments

    validates_each :answers do |record, _attr, _value|
      record.category_assessments.each do |category_assessment, _all_answered|
        key = category_assessment.id
        value = record.public_send(key)

        record.errors.add(key, 'Select if any exemptions apply') if value == NO_ANSWER_WAS_GIVEN
      end
    end

    validate :check_ambiguous_exemptions

    def check_ambiguous_exemptions
      if ambiguous_exemptions.any?
        errors.add(:base, 'A condition has only been selected once. If you meet this condition, select it wherever it appears on this page.')
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
      !answers.values.flatten.include?(NONE_ANSWER_WAS_GIVEN)
    end

    def presented_answers
      answers.each_with_object({}) do |(key, value), acc|
        acc[key.split('_').last] = value.select(&:present?)
      end
    end

    private

    # Output: A list of exemptions (conditions) that appear more than once in the form,
    #         where the user has selected only one of the occurrences.
    def ambiguous_exemptions
      answered_exemptions = answers.values.flatten.reject { |e| ['none', ''].include?(e) }

      count_answers = answered_exemptions.group_by { |code| code }
                                         .transform_values(&:count)

      count_answers.reject { |code, count| count == exemptions_count[code] }
                   .keys
    end

    def exemptions_count
      all_exemptions = category_assessments.flat_map do |ca|
        ca.exemptions.map(&:resource_id)
      end

      all_exemptions.group_by { |code| code }
                    .transform_values(&:count)
    end
  end
end
