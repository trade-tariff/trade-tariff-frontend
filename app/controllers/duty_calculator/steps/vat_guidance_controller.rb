module DutyCalculator
  module Steps
    class VatGuidanceController < BaseController
      SESSION_KEY = 'duty_calculator_vat_guidance'.freeze
      TREATMENT_TO_VAT = {
        'standard' => 'VAT',
        'reduced' => 'VATR',
        'zero' => 'VATZ',
      }.freeze

      before_action :load_journey, only: %i[question answer result]

      rescue_from VatGuidancePrototype::ComposedJourneyRepository::JourneyNotFound, with: :return_to_vat
      rescue_from VatGuidancePrototype::ComposedJourneyRepository::InvalidArtifact,
                  Faraday::Error,
                  SystemCallError,
                  with: :return_to_vat

      def start
        journey_id = params[:journey_id].presence || user_session.commodity_code
        journey = repository.for_commodity(user_session.commodity_code).find { |candidate| candidate.id == journey_id }
        raise VatGuidancePrototype::ComposedJourneyRepository::JourneyNotFound, journey_id unless journey

        session[SESSION_KEY] = { 'journey_id' => journey.id, 'answers' => [] }

        redirect_to vat_guidance_question_path
      end

      def question
        @state = engine.evaluate(session_data['answers'])
        return redirect_to vat_guidance_result_path unless @state.question?

        @question = @state.question
        @answer_form = VatGuidancePrototype::AnswerForm.new(question: @question)
      end

      def answer
        @state = engine.evaluate(session_data['answers'])
        return redirect_to vat_guidance_result_path unless @state.question?

        @question = @state.question
        @answer_form = VatGuidancePrototype::AnswerForm.new(question: @question, answer: answer_params[:answer])

        if @answer_form.valid?
          session_data['answers'] << { 'question_id' => @question.id, 'answer_id' => @answer_form.answer }
          session[SESSION_KEY] = session_data

          destination = engine.evaluate(session_data['answers']).question? ? vat_guidance_question_path : vat_guidance_result_path
          redirect_to destination
        else
          render :question, status: :unprocessable_content
        end
      end

      def result
        @state = engine.evaluate(session_data['answers'])
        return redirect_to vat_guidance_question_path if @state.question?

        if @journey.evidence_only
          session_data.delete('candidate_vat')
        else
          session_data['candidate_vat'] = TREATMENT_TO_VAT.fetch(@state.route.fetch('treatment'))
        end
        session[SESSION_KEY] = session_data
      end

    private

      def repository
        @repository ||= VatGuidancePrototype::ComposedJourneyRepository.new
      end

      def load_journey
        return return_to_vat if session_data['journey_id'].blank?

        @journey = repository.for_commodity(user_session.commodity_code).find do |candidate|
          candidate.id == session_data['journey_id']
        end
        raise VatGuidancePrototype::ComposedJourneyRepository::JourneyNotFound, session_data['journey_id'] unless @journey
      end

      def engine
        @engine ||= VatGuidancePrototype::ComposedRouteEngine.new(journey: @journey)
      end

      def session_data
        @session_data ||= session[SESSION_KEY] || { 'answers' => [] }
      end

      def answer_params
        params.fetch(:vat_guidance_prototype_answer_form, {}).permit(:answer)
      end

      def return_to_vat(_error = nil)
        redirect_to vat_path, alert: 'Guided VAT questions are not available for this commodity.'
      end
    end
  end
end
