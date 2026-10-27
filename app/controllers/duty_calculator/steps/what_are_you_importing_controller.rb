module DutyCalculator
  module Steps
    class WhatAreYouImportingController < ::DutyCalculator::ApplicationController
      default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

      before_action :ensure_uk_service
      before_action :ensure_duty_calculator_feature_enabled

      def show
        @step = Steps::WhatAreYouImporting.new
      end

      def create
        @step = Steps::WhatAreYouImporting.new(permitted_params)
        return render :show unless @step.valid?

        @step.save!
        redirect_to perform_search_path(search_params)
      end

      def search
        @step = Steps::WhatAreYouImporting.new(search_term: params[:q])
        search_form = InteractiveSearchForm.new(q: params[:q], request_id: params[:request_id])
        unless search_form.valid?
          search_form.errors.each { |error| @step.errors.add(:search_term, error.message) }
          return render :show
        end

        @step.search_term = search_form.q
        @step.save!
        redirect_to perform_search_path(standard_search_params)
      end

    private

      def permitted_params
        params.require(:duty_calculator_steps_what_are_you_importing).permit(:search_term)
      end

      def search_params
        params = { q: @step.search_term, interactive_search: true, duty_calculator: true }
        return params if user_session.import_date.blank?

        params.merge(
          day: user_session.import_date.day,
          month: user_session.import_date.month,
          year: user_session.import_date.year,
        )
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
        ).to_h.merge(search_params_for_session).merge(duty_calculator: true)
      end

      def search_params_for_session
        return {} if user_session.import_date.blank?

        {
          day: user_session.import_date.day,
          month: user_session.import_date.month,
          year: user_session.import_date.year,
        }
      end

      def ensure_uk_service
        raise TradeTariffFrontend::FeatureUnavailable unless TradeTariffFrontend::ServiceChooser.uk?
      end
    end
  end
end
