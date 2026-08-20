module VatGuidancePrototype
  class JourneysController < ApplicationController
    SESSION_KEY = 'vat_guidance_prototype'.freeze

    before_action :prepare_prototype_page
    before_action :load_journey, only: %i[question answer result]

    rescue_from RuleRepository::JourneyNotFound, with: :render_not_found

    def index
      session.delete(SESSION_KEY)
      @journeys = repository.all
    end

    def start
      journey = repository.find(params.require(:journey_id))
      session[SESSION_KEY] = { 'journey_id' => journey.id, 'answers' => {} }

      redirect_to vat_guidance_prototype_question_path
    end

    def question
      @state = engine.evaluate(session_data['answers'])
      return redirect_to vat_guidance_prototype_result_path unless @state.question?

      @question = @state.question
      @answer_form = AnswerForm.new(question: @question)
    end

    def answer
      @state = engine.evaluate(session_data['answers'])
      return redirect_to vat_guidance_prototype_result_path unless @state.question?

      @question = @state.question
      @answer_form = AnswerForm.new(question: @question, answer: answer_params[:answer])

      if @answer_form.valid?
        session_data['answers'][@question.id] = @answer_form.answer
        session[SESSION_KEY] = session_data

        destination = if engine.evaluate(session_data['answers']).question?
                        vat_guidance_prototype_question_path
                      else
                        vat_guidance_prototype_result_path
                      end
        redirect_to destination
      else
        render :question, status: :unprocessable_content
      end
    end

    def result
      @state = engine.evaluate(session_data['answers'])
      return redirect_to vat_guidance_prototype_question_path if @state.question?

      @vat_option_label = @journey.applicable_vat_options[@state.vat_option]
    end

  private

    def prepare_prototype_page
      disable_search_form
      disable_switch_service_banner
      skip_news_banner
    end

    def repository
      @repository ||= RuleRepository.new
    end

    def load_journey
      if session_data['journey_id'].blank?
        redirect_to vat_guidance_prototype_root_path
        return
      end

      @journey = repository.find(session_data['journey_id'])
    end

    def engine
      @engine ||= DecisionEngine.new(journey: @journey)
    end

    def session_data
      @session_data ||= session[SESSION_KEY] || { 'answers' => {} }
    end

    def answer_params
      params.fetch(:vat_guidance_prototype_answer_form, {}).permit(:answer)
    end

    def render_not_found
      raise ActionController::RoutingError, 'VAT guidance prototype journey not found'
    end
  end
end
