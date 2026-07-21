module VatGuidancePrototype
  class AnswerForm
    include ActiveModel::Model

    attr_accessor :answer
    attr_reader :question

    validates :answer, presence: true
    validate :answer_is_supported

    def initialize(question:, answer: nil)
      @question = question
      super(answer:)
    end

    def options
      question.answers.map { |candidate| Option.new(id: candidate.id, name: candidate.label) }
    end

  private

    Option = Data.define(:id, :name)

    def answer_is_supported
      return if answer.blank? || question.answers.any? { |candidate| candidate.id == answer }

      errors.add(:answer, 'Select one of the available answers')
    end
  end
end
