module DutyCalculator
  class DutyCalculator
    include CommodityHelper

    def initialize(commodity)
      @commodity = commodity
    end

    def options
      options = commodity.applicable_measures.select(&:applicable?).each_with_object(default_options) do |measure, acc|
        option_klass = measure.measure_type.option

        next if option_klass.nil?

        acc << option_klass.new(measure, additional_duty_rows_for(option_klass), vat_measure).call
      end

      options.sort_by(&:priority)
    end

  private

    attr_reader :commodity

    def additional_duty_rows_for(option_klass)
      rows = AdditionalDutyApplicableMeasuresMerger.new.call.each_with_object([]) do |measure, acc|
        additional_duty_option_klass = measure.measure_type.additional_duty_option

        next if additional_duty_option_klass.nil?
        next if option_klass.excludes?(additional_duty_option_klass)
        next if measure.all_duties_zero?

        acc << additional_duty_option_klass.new(measure, [], nil).call
      end

      rows.sort_by(&:priority)
    end

    def default_options
      return OptionCollection.new([waiver_option]) if user_session.gb_to_ni_route?

      OptionCollection.new([])
    end

    def waiver_option
      DutyOptions::Waiver.new(nil, [], nil).call
    end

    def vat_measure
      @vat_measure ||= begin
        vat_measures = uk_filtered_commodity.import_measures.select(&:vat)

        return vat_measures.first if vat_measures.size == 1

        vat_measures.find { |measure| measure.vat_type == user_session.vat }
      end
    end

    def user_session
      UserSession.get
    end
  end
end
