module VatGuidancePrototype
  class ComposedRouteEngine
    InvalidAnswer = Class.new(StandardError)
    InvalidRoutes = Class.new(StandardError)

    Answer = Data.define(:id, :label)
    Question = Data.define(:id, :text, :answers)
    TrailItem = Data.define(:question, :answer, :evidence)

    State = Data.define(:status, :question, :route, :reason, :trail) do
      def question?
        status == :question
      end

      def determined?
        status == :determined
      end
    end

    def initialize(journey:)
      @journey = journey
    end

    def evaluate(raw_answers = [])
      answers = normalize_answers(raw_answers)
      candidates = matching_routes(answers)
      raise InvalidAnswer, 'The answers do not match a composed route' if candidates.empty?

      completed = candidates.select { |route| route.fetch('steps').length == answers.length }
      if completed.any?
        raise InvalidRoutes, 'A completed route overlaps an unfinished route' unless completed.length == candidates.length
        raise InvalidRoutes, 'The answers resolve to more than one route' unless completed.one?

        route = completed.sole
        return State.new(status: :determined, question: nil, route:, reason: nil, trail: build_trail(route, answers))
      end

      State.new(
        status: :question,
        question: build_question(candidates, answers.length),
        route: nil,
        reason: nil,
        trail: build_trail(candidates.first, answers),
      )
    end

  private

    attr_reader :journey

    def normalize_answers(raw_answers)
      Array(raw_answers).map do |answer|
        answer = answer.stringify_keys
        answer.slice('question_id', 'answer_id').tap do |normalized|
          unless normalized.values.all?(&:present?)
            raise InvalidAnswer, 'Each answer must identify a question and answer'
          end
        end
      end
    end

    def matching_routes(answers)
      journey.routes.select do |route|
        steps = route.fetch('steps')
        next false if steps.length < answers.length

        answers.each_with_index.all? do |answer, index|
          step = steps.fetch(index)
          step['question_id'] == answer['question_id'] && step['answer_id'] == answer['answer_id']
        end
      end
    end

    def build_question(routes, index)
      steps = routes.map { |route| route.fetch('steps').fetch(index) }
      question_ids = steps.pluck('question_id').uniq
      question_texts = steps.pluck('question').uniq
      unless question_ids.one? && question_texts.one?
        raise InvalidRoutes, 'Composed routes disagree on the next question'
      end

      answers = steps.group_by { |step| step.fetch('answer_id') }.map do |id, answer_steps|
        labels = answer_steps.pluck('answer').uniq
        raise InvalidRoutes, "Composed routes disagree on answer #{id}" unless labels.one?

        Answer.new(id:, label: labels.sole)
      end

      Question.new(id: question_ids.sole, text: question_texts.sole, answers: answers.sort_by(&:id))
    end

    def build_trail(route, answers)
      answers.each_with_index.map do |answer, index|
        step = route.fetch('steps').fetch(index)
        question = Question.new(id: step.fetch('question_id'), text: step.fetch('question'), answers: [])
        selected_answer = Answer.new(id: answer.fetch('answer_id'), label: step.fetch('answer'))
        TrailItem.new(question:, answer: selected_answer, evidence: step['evidence'])
      end
    end
  end
end
