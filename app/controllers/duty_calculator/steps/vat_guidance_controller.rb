module DutyCalculator
  module Steps
    class VatGuidanceController < BaseController
      SESSION_KEY = 'vat_guidance'.freeze

      before_action :ensure_feature_enabled
      before_action :load_coverage

      def show
        reset_answers if params[:restart].present? || guidance_session['commodity_code'] != commodity_code
        return redirect_to confirm_path if @coverage.not_eligible?

        prepare_question_or_redirect
      end

      def answer
        return redirect_to vat_guidance_path unless @coverage.guided?

        @state = engine.evaluate(guidance_session['answers'])
        return redirect_to vat_guidance_result_path unless @state.question?

        @question = @state.question
        @answer_form = VatGuidancePrototype::AnswerForm.new(
          question: @question,
          answer: answer_params[:answer],
        )

        if @answer_form.valid?
          guidance_session['answers'][@question.id] = @answer_form.answer
          session[SESSION_KEY] = guidance_session
          redirect_to engine.evaluate(guidance_session['answers']).question? ? vat_guidance_path : vat_guidance_result_path
        else
          render :show, status: :unprocessable_content
        end
      end

      def result
        return redirect_to vat_guidance_path unless @coverage.guided?

        @state = engine.evaluate(guidance_session['answers'])
        return redirect_to vat_guidance_path if @state.question?

        @vat_option_label = applicable_vat_options[@state.vat_option]
      end

      def apply
        return redirect_to vat_guidance_path unless @coverage.guided?

        state = engine.evaluate(guidance_session['answers'])
        return redirect_to vat_guidance_result_path unless state.determined?

        user_session.vat = state.vat_option
        session.delete(SESSION_KEY)
        redirect_to confirm_path
      end

    private

      def ensure_feature_enabled
        redirect_to vat_path unless TradeTariffFrontend.vat_guidance_enabled?
      end

      def load_coverage
        @coverage = VatGuidancePrototype::CoverageAssessment.new(
          commodity_code:,
          vat_options: applicable_vat_options,
          as_of: user_session.import_date || Time.zone.today,
          jurisdiction: :uk,
        ).call
        @journey = @coverage.journey
      end

      def prepare_question_or_redirect
        @state = engine.evaluate(guidance_session['answers'])
        return redirect_to vat_guidance_result_path unless @state.question?

        @question = @state.question
        @answer_form = VatGuidancePrototype::AnswerForm.new(question: @question)
      end

      def engine
        @engine ||= VatGuidancePrototype::DecisionEngine.new(
          journey: @journey,
          applicable_vat_options:,
        )
      end

      def guidance_session
        @guidance_session ||= session[SESSION_KEY] || {
          'commodity_code' => commodity_code,
          'answers' => {},
        }
      end

      def reset_answers
        @guidance_session = {
          'commodity_code' => commodity_code,
          'answers' => {},
        }
        session[SESSION_KEY] = @guidance_session
      end

      def answer_params
        params.fetch(:vat_guidance_prototype_answer_form, {}).permit(:answer)
      end
    end
  end
end
