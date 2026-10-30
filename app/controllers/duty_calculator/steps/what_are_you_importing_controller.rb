module DutyCalculator
  module Steps
    class WhatAreYouImportingController < ::DutyCalculator::ApplicationController
      include QueuedGuidedSearchable

      default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

      before_action :ensure_uk_service
      before_action :ensure_duty_calculator_feature_enabled

      def show = @step = Steps::WhatAreYouImporting.new

      def create
        @step = Steps::WhatAreYouImporting.new(permitted_params)
        return render :show unless @step.valid?

        @step.save!
        redirect_to perform_search_path(search_params)
      end

      def search
        request_id = params[:request_id].to_s
        request_id = SecureRandom.uuid unless request_id.match?(Search::GUIDED_REQUEST_ID_PATTERN)
        record_direct_initial_submission(request_id)

        @step = Steps::WhatAreYouImporting.new(search_term: params[:q])
        search_form = InteractiveSearchForm.new(q: params[:q], request_id: params[:request_id])
        unless search_form.valid?
          search_form.errors.each { |error| @step.errors.add(:search_term, error.message) }
          record_input_error(request_id)
          return render :show
        end

        @step.search_term = search_form.q
        unless @step.valid?
          record_input_error(request_id)
          return render :show
        end

        @step.save!
        redirect_to perform_search_path(standard_search_params.merge(request_id:))
      end

    private

      def record_direct_initial_submission(request_id)
        return if params[:queued_search_id].present? || params[:telemetry_submission_id].present?

        GuidedSearch::JourneyInstrumentation.record(
          browser_session_id:,
          request_id:,
          experiment: Current.experiment,
          outcome: 'initial_submitted',
          submission_source: 'server_direct',
          submission_id: SecureRandom.uuid,
          event_id: SecureRandom.uuid,
        )
      rescue StandardError => e
        Rails.logger.warn("Failed to record calculator initial submission: #{e.class}: #{e.message}")
        nil
      end

      def record_input_error(request_id)
        GuidedSearch::JourneyInstrumentation.record(
          browser_session_id:,
          request_id:,
          experiment: Current.experiment,
          outcome: 'input_error',
        )
      rescue StandardError => e
        Rails.logger.warn("Failed to record calculator input error: #{e.class}: #{e.message}")
        nil
      end

      def permitted_params = params.require(:duty_calculator_steps_what_are_you_importing).permit(:search_term)

      def search_params
        { q: @step.search_term,
          interactive_search: true,
          duty_calculator: true }.merge(import_date_params)
      end

      def standard_search_params
        params.permit(
          :q,
          :interactive_search,
          :request_id,
          :queued_search_id,
          :queued_search_token,
          :expanded_query,
          :query_expansion,
          :day,
          :month,
          :year,
          answers: %i[question answer options],
        ).to_h.merge(import_date_params.stringify_keys).merge('duty_calculator' => 'true')
      end

      def import_date_params = user_session.import_date&.then { |d| { day: d.day, month: d.month, year: d.year } } || {}
    end
  end
end
