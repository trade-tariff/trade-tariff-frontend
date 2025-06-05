module DutyCalculator
  module Api
    class Commodity < Api::Base
      has_many :import_measures, Measure
      has_many :export_measures, Measure

      meta_attribute :duty_calculator, :applicable_measure_units
      meta_attribute :duty_calculator, :applicable_additional_codes
      meta_attribute :duty_calculator, :applicable_vat_options
      meta_attribute :duty_calculator, :trade_defence
      meta_attribute :duty_calculator, :zero_mfn_duty
      meta_attribute :duty_calculator, :source

      attributes :id,
                 :producline_suffix,
                 :number_indents,
                 :description,
                 :goods_nomenclature_item_id,
                 :bti_url,
                 :formatted_description,
                 :description_plain,
                 :consigned,
                 :consigned_from,
                 :basic_duty_rate,
                 :meursing_code,
                 :declarable,
                 :footnotes,
                 :section,
                 :chapter,
                 :heading,
                 :ancestors

      alias_method :meursing_code?, :meursing_code

      def description
        attributes[:description].html_safe
      end

      def code
        goods_nomenclature_item_id
      end

      def formatted_commodity_code(additional_code = nil)
        formatted_code = "#{code[0..3]} #{code[4..5]} #{code[6..7]} #{code[8..9]}"
        return formatted_code if additional_code.blank?

        additional_code = 'No additional code' if additional_code == 'none'

        "#{formatted_code} (#{additional_code})".html_safe
      end

      def applicable_measures
        @applicable_measures ||= no_additional_code_measures + additional_code_measures
      end

      def applicable_excise_measure_units
        applicable_measure_units.select do |unit, _value|
          unit.in?(excise_measure_units)
        end
      end

      def applicable_excise_measures
        @applicable_excise_measures ||= applicable_measures.select(&:excise)
      end

      def rules_of_origin_schemes
        raise Errors::SessionIntegrityError, 'origin_country_code' if user_session.origin_country_code.blank?

        RulesOfOriginScheme.build_collection(
          source,
          nil,
          heading_code: goods_nomenclature_item_id.first(6),
          country_code: user_session.origin_country_code,
        )
      end

      def stopping_conditions_met?
        stopping_measures.any? &&
          stopping_measures.any?(&:stopping_condition_met?)
      end

      def stopping_measures
        applicable_measures.select(&:stopping?)
      end

      private

      def excise_measure_units
        @excise_measure_units ||= excise_measures.flat_map(&:all_units).uniq
      end

      def excise_measures
        @excise_measures ||= import_measures.select(&:excise)
      end

      def no_additional_code_measures
        non_vat_import_measures.reject do |measure|
          measure.id.in?(additional_code_measure_sids)
        end
      end

      def additional_code_measures
        non_vat_import_measures.select do |measure|
          answer = if measure.measure_type.excise?
                     "X#{user_session.excise_additional_code_for(measure.measure_type.id)}"
                   else
                     user_session.additional_code_for(measure.measure_type.id, source)
                   end

          code = measure.additional_code.presence&.code || 'none'

          is_additional_code_measure = measure.id.in?(additional_code_measure_sids)
          has_answer = answer == code

          is_additional_code_measure && has_answer
        end
      end

      def has_none_additional_code(measure)
        return false if applicable_additional_codes.blank?

        additional_codes_have_measure_type?(measure.measure_type.id) &&
          additional_codes_has_none_option?(measure.measure_type.id)
      end

      def additional_codes_have_measure_type?(measure_type_id)
        measure_type_id.in?(applicable_additional_codes.keys)
      end

      def additional_codes_has_none_option?(measure_type_id)
        applicable_additional_codes.dig(measure_type_id, 'additional_codes').any? do |co|
          co['code'] == 'none'
        end
      end

      def non_vat_import_measures
        import_measures.reject(&:vat)
      end

      def additional_code_measure_sids
        @additional_code_measure_sids ||= if applicable_additional_codes.blank?
                                            []
                                          else
                                            applicable_additional_codes.values.flat_map do |values|
                                              values['additional_codes'].pluck('measure_sid')
                                            end
                                          end
      end
    end
  end
end
