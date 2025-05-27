module DutyCalculator
  class NumberWithHighPrecisionFormatter
    include ActionView::Helpers::NumberHelper

    def initialize(quantity, min_precision: 2, max_precision: 10)
      @quantity = quantity
      @max_precision = max_precision
      @min_precision = min_precision
    end

    def call
      number_with_precision(
        @quantity,
        precision:,
        significant: false,
        strip_insignificant_zeros:,
      )
    end

  private

    def precision
      return @min_precision if low_precision? && !scientific_notation?

      @max_precision || 10
    end

    def strip_insignificant_zeros
      return false if low_precision? && !scientific_notation?

      true
    end

    def scientific_notation?
      /e/.match? @quantity.to_s
    end

    def low_precision?
      (/(\.$|\.\d$)/.match? @quantity.to_s) || (/\./ !~ @quantity.to_s)
    end
  end
end
