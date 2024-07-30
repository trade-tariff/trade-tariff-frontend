module GreenLanes
  class AssessmentsPresenter < SimpleDelegator
    def initialize(category, answers)
      super(category)

      @answers = answers
    end

    def no_cat1_exemptions
      cat1_with_exemptions.all? { |ca| ca.exemptions.none? }
    end

    def no_cat2_exemptions
      cat2_with_exemptions.all? { |ca| ca.exemptions.none? }
    end

    def no_exemptions
      no_cat1_exemptions && no_cat2_exemptions
    end

    def cat_1_exemptions
      extract_exemptions(cat1_with_exemptions)
    end

    def cat_2_exemptions
      extract_exemptions(cat2_with_exemptions)
    end

    def cat_1_exemptions_met
      process_exemptions(@answers['1'])
    end

    def cat_2_exemptions_met
      process_exemptions(@answers['2'])
    end

    def no_exemptions_met
      cat_1_exemptions_met.empty? && cat_2_exemptions_met.empty?
    end

    def cat_1_exemptions_not_met
      exemptions_not_met(cat1_with_exemptions, cat_1_exemptions_met)
    end

    def cat_2_exemptions_not_met
      exemptions_not_met(cat2_with_exemptions, cat_2_exemptions_met)
    end

    def exemptions_not_met(cat_with_exemptions, exemptions_met)
      cat_with_exemptions.reject do |ca|
        ca_exemption_codes = ca.exemptions.map(&:code)

        exemptions_met.any? { |answer| answer.in?(ca_exemption_codes) }
      end
    end

    private

    def extract_exemptions(category_assessments)
      category_assessments.flat_map { |ca| ca.exemptions.map(&:code) }
    end

    def process_exemptions(exemptions)
      return [] if exemptions.nil?

      filtered_exemptions = exemptions.values.flatten.reject { |val| val == 'none' }
      filtered_exemptions.empty? ? [] : filtered_exemptions
    end
  end
end
