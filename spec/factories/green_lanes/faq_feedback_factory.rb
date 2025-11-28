FactoryBot.define do
  factory :green_lanes_faq_feedback, class: 'FaqFeedback' do
    initialize_with { new }

    transient do
      session_id { '12345ABCDEF' }
      category_id { 1 }
      question_id { 2 }
      useful { true }
    end

    after(:build) do |faq_feedback, evaluator|
      faq_feedback.define_singleton_method(:session_id) { evaluator.session_id }
      faq_feedback.define_singleton_method(:category_id) { evaluator.category_id }
      faq_feedback.define_singleton_method(:question_id) { evaluator.question_id }
      faq_feedback.define_singleton_method(:useful) { evaluator.useful }
    end
  end
end
