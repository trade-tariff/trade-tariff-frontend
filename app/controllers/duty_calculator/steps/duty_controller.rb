module DutyCalculator
  module Steps
    class DutyController < BaseController
      helper_method :title

      def show
        @duty_options = duty_options
        @gbp_to_eur_exchange_rate = Api::MonetaryExchangeRate.for('GBP').exchange_rate.round(4) unless user_session.import_into_gb?
        @rules_of_origin_schemes = uk_filtered_commodity.rules_of_origin_schemes
      end

      private

      def duty_options
        return nil if user_session.no_duty_to_pay?
        return send("#{user_session.commodity_source}_options") unless user_session.deltas_applicable?

        RowToNiDutyCalculator.new(uk_options, xi_options).options if user_session.deltas_applicable?
      end

      def uk_options
        @uk_options ||= DutyCalculator.new(uk_filtered_commodity).options
      end

      def xi_options
        @xi_options ||= DutyCalculator.new(xi_filtered_commodity).options
      end

      def title
        @duty_options.present? ? t('page_titles.duty_calculation') : t('page_titles.no_duty')
      end
    end
  end
end
