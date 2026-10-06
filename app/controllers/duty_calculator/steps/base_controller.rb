module DutyCalculator
  module Steps
    class BaseController < ::DutyCalculator::ApplicationController
      include CommodityHelper
      include ServiceHelper
      include UkimsHelper

      rescue_from Errors::SessionIntegrityError, with: :handle_session_integrity_error
      # Must be declared before rescue_from StandardError so it is matched first.
      # Rails stores handlers in definition order and picks the first match. A missing
      # commodity is an expected condition — the API returns 404 when a code doesn't
      # exist or isn't declarable. We redirect silently rather than surfacing it in NewRelic.
      rescue_from Faraday::ResourceNotFound, with: :handle_commodity_not_found
      rescue_from StandardError, with: :handle_exception

      default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
      before_action :ensure_session_integrity
      before_action :initialize_commodity_context_service
      before_action :set_ux_improvements_variant

      helper_method :commodity_code,
                    :commodity_source,
                    :country_of_origin_description,
                    :duty_calculator_ux_improvements?,
                    :title,
                    :user_session

      def country_of_origin_description
        Api::GeographicalArea.build(
          user_session.import_destination.downcase.to_sym,
          country_of_origin_code.upcase,
        ).description
      end

      protected

      def validate(step)
        if step.valid?
          step.save!

          redirect_to path_after_save(step)
        else
          render 'show'
        end
      end

      def path_after_save(step)
        next_step_path = step.next_step_path
        return next_step_path unless duty_calculator_ux_improvements? && user_session.return_to_confirm

        can_return_to_confirm?(next_step_path) ? confirm_path : next_step_path
      end

      # After a Change link from Check your answers, go straight back to the
      # summary unless a later answer has to be given again.
      def can_return_to_confirm?(next_step_path)
        return true if next_step_path == confirm_path
        return false unless next_step_path == vat_path

        user_session.vat.present? && applicable_vat_options.key?(user_session.vat)
      end

      def set_ux_improvements_variant
        request.variant = :ux if duty_calculator_ux_improvements?
      end

      def commodity_code
        params[:commodity_code] || user_session.commodity_code
      end

      def commodity_source
        params[:referred_service] || user_session.commodity_source
      end

      def handle_exception(exception)
        with_session_tracking do
          raise exception
        end
      end

      def handle_session_integrity_error(exception)
        with_session_tracking do
          NewRelic::Agent.notice_error(exception)
          redirect_to sections_url, allow_other_host: true
        end
      end

      def handle_commodity_not_found(_exception)
        redirect_to sections_url, allow_other_host: true
      end

      def ensure_session_integrity
        handle_session_integrity_error(Errors::SessionIntegrityError.new('commodity_code')) if commodity_code.blank?
      end

      def initialize_commodity_context_service
        Thread.current[:commodity_context_service] = CommodityContextService.new
      end

      def title
        t("page_titles.#{@step.class.try(:id)}", default: t("title.#{service_name}"))
      end

      def with_session_tracking
        yield
      end

      delegate :service_name, to: ::TradeTariffFrontend::ServiceChooser
    end
  end
end
