module VatGuidancePrototype
  class DecisionEngine
    InvalidAnswer = Class.new(StandardError)

    State = Data.define(:status, :question, :vat_option, :reason, :trail) do
      def question?
        status == :question
      end

      def determined?
        status == :determined
      end

      def unable?
        status == :unable
      end
    end

    def initialize(journey:, applicable_vat_options: journey.applicable_vat_options)
      @journey = journey
      @applicable_vat_options = applicable_vat_options.stringify_keys
    end

    def evaluate(answers = {})
      answers = answers.stringify_keys
      question_id = journey.start_question
      trail = []

      loop do
        question = journey.questions.fetch(question_id)
        answer_id = answers[question_id]
        return State.new(status: :question, question:, vat_option: nil, reason: nil, trail:) if answer_id.blank?

        answer = question.answers.find { |candidate| candidate.id == answer_id }
        raise InvalidAnswer, "#{answer_id} is not an answer to #{question_id}" unless answer

        trail << { question:, answer: }

        if answer.next_question
          question_id = answer.next_question
        elsif answer.outcome
          return outcome_state(answer.outcome, trail)
        else
          return State.new(status: :unable, question: nil, vat_option: nil, reason: answer.unable_reason, trail:)
        end
      end
    end

  private

    attr_reader :journey, :applicable_vat_options

    def outcome_state(vat_option, trail)
      unless applicable_vat_options.key?(vat_option)
        return State.new(
          status: :unable,
          question: nil,
          vat_option: nil,
          reason: 'The rule produced a VAT option that is not available in the current tariff data.',
          trail:,
        )
      end

      State.new(status: :determined, question: nil, vat_option:, reason: nil, trail:)
    end
  end
end
