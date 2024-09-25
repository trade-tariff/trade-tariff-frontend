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
      extract_exemption_codes(cat1_with_exemptions)
    end

    def cat_2_exemptions
      extract_exemption_codes(cat2_with_exemptions)
    end

    def cat_1_exemptions_met
      return [] if @answers.nil?

      applicable_exemptions(@answers['1'])
    end

    def cat_2_exemptions_met
      return [] if @answers.nil?

      puts ">>> @answers['2'] = #{@answers['2']}"
      puts "class = #{@answers['2'].class}"


      applicable_exemptions(@answers['2'])
    end

    def cat_1_assessments
      cat1_with_exemptions
    end

    def cat_2_assessments
      cat2_with_exemptions
    end

    def cat_1_assessments_met
      return [] if @answers.nil?

      exempt_category_assessments(@answers['1'])
    end

    def cat_2_assessments_met
      return [] if @answers.nil?

      exempt_category_assessments(@answers['2'])
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

    def extract_exemption_codes(category_assessments)
      category_assessments.flat_map { |ca| ca.exemptions.map(&:code) }
    end

    def applicable_exemptions(answers)
      puts ">>> answers = #{answers}"
      filtered_exemptions = answers.values.flatten.reject { |val| val == 'none' }
      puts ">>> filtered_exemptions = #{filtered_exemptions}"
      filtered_exemptions.empty? ? [] : filtered_exemptions
    end

    def exempt_category_assessments(answers)
      # Returns array of the category assessment ids that trader is exempt.
      return [] if answers.nil?

      answers.select { |_key, values|
        values.any? { |value| !value.empty? && value != 'none' }
      }.keys
    end
  end
end
