module DutyCalculator
  module Api
    class MonetaryExchangeRate < Api::Base
      attributes :id,
                 :child_monetary_unit_code,
                 :exchange_rate,
                 :operation_date,
                 :validity_start_date

      def validity_start_date
        Date.parse(attributes[:validity_start_date])
      end

      def exchange_rate
        attributes[:exchange_rate].to_f
      end

      class << self
        def for(currency)
          applicable_monetary_exchange_rates = build_collection(:xi).select do |monetary_exchange_rate|
            monetary_exchange_rate.child_monetary_unit_code == currency.upcase
          end

          closest_monetary_exchange_rate = applicable_monetary_exchange_rates.find do |monetary_exchange_rate|
            monetary_exchange_rate.validity_start_date.year == import_date.year &&
              monetary_exchange_rate.validity_start_date.month == import_date.month
          end

          # Return the exchange rate that applies to the month or fallback on the latest available exchange rate
          closest_monetary_exchange_rate || applicable_monetary_exchange_rates.max_by(&:validity_start_date)
        end

        def import_date
          UserSession.get&.import_date || Time.zone.now
        end
      end
    end
  end
end
