module DutyCalculator
  module Api
    class Measure < Api::Base
      has_many :measure_conditions, MeasureCondition
      has_many :measure_components, MeasureComponent
      has_many :resolved_measure_components, MeasureComponent

      has_one :measure_type, MeasureType
      has_one :geographical_area, GeographicalArea
      has_one :duty_expression, DutyExpression
      has_one :order_number, OrderNumber
      has_one :additional_code, AdditionalCode
      has_one :suspension_legal_act, SuspensionLegalAct

      meta_attribute :duty_calculator, :source
      meta_attribute :duty_calculator, :scheme_code

      attributes :id,
                 :effective_end_date,
                 :effective_start_date,
                 :excise,
                 :excluded_countries,
                 :footnotes,
                 :import,
                 :legal_acts,
                 :meursing,
                 :national_measurement_units,
                 :origin,
                 :reduction_indicator,
                 :resolved_duty_expression,
                 :vat

      alias_method :excise?, :excise

      def document_codes
        measure_conditions.map do |measure_condition|
          {
            code: measure_condition.document_code,
            description: measure_condition.certificate_description,
          }
        end
      end

      def evaluator
        if ad_valorem?
          ExpressionEvaluators::AdValorem.new(self, component)
        elsif retail_price?
          ExpressionEvaluators::RetailPrice.new(self, component)
        elsif specific_duty? && component.alcohol_volume?
          ExpressionEvaluators::AlcoholVolumeMeasureUnit.new(self, component)
        elsif specific_duty? && component.sucrose?
          ExpressionEvaluators::SucroseMeasureUnit.new(self, component)
        elsif specific_duty?
          ExpressionEvaluators::MeasureUnit.new(self, component)
        else
          ExpressionEvaluators::Compound.new(self, nil)
        end
      end

      # Compound components (where there are more than one) need to be evaluated by each individual component and have slightly different logic
      def evaluator_for_compound_component(component)
        if component.ad_valorem?
          ExpressionEvaluators::AdValorem.new(self, component)
        elsif component.retail_price?
          ExpressionEvaluators::RetailPrice.new(self, component)
        elsif component.alcohol_volume?
          ExpressionEvaluators::AlcoholVolumeMeasureUnit.new(self, component)
        elsif component.sucrose?
          ExpressionEvaluators::SucroseMeasureUnit.new(self, component)
        elsif component.spq?
          ExpressionEvaluators::Spq.new(self, component)
        elsif component.specific_duty?
          ExpressionEvaluators::MeasureUnit.new(self, component)
        end
      end

      def component
        @component ||= applicable_components.first
      end

      def applicable_components
        @applicable_components ||= document_components.presence ||
          threshold_condition_components.presence ||
          resolved_measure_components.presence ||
          measure_components
      end

      def all_duties_zero?
        return false if vat.present?

        applicable_components.all? { |component| component.duty_amount.zero? }
      end

      def vat_type
        return if vat.blank?
        return 'VAT' if additional_code.blank? || additional_code.attributes.values.all?(&:blank?)

        additional_code.code
      end

      # Measures are always applicable unless they have a condition which makes them conditionally applicable
      # depending on the expressed requirement of the condition.
      def applicable?
        return true if applicable_document_condition.blank? && applicable_threshold_condition.blank?
        return applicable_document_condition.applicable? if applicable_document_condition.present?

        applicable_threshold_condition.applicable?
      end

      def expresses_document?
        measure_conditions.any?(&:expresses_document?)
      end

      def all_units
        all_components.map(&:unit).compact
      end

      def stopping?
        measure_conditions&.any?(&:stopping?)
      end

      def stopping_condition_met?
        applicable_document_condition&.stopping?
      end

      def applicable_document_condition
        @applicable_document_condition ||= begin
          document_code = user_session.document_code_for(measure_type.id, source)

          return if document_code.nil?

          measure_conditions.find do |measure_condition|
            measure_condition.document_code == document_code
          end
        end
      end

      def applicable_threshold_condition
        @applicable_threshold_condition ||= begin
          return unless excise?

          measure_conditions.find do |candidate_measure_condition|
            unit_answer = user_session.measure_amount_for(candidate_measure_condition.condition_measurement_unit)
            unit_answer = unit_answer.to_f if unit_answer.present?

            next unless candidate_measure_condition.expresses_unit? && unit_answer.present?

            unit_answer.public_send(
              candidate_measure_condition.requirement_operator,
              candidate_measure_condition.condition_duty_amount.to_f,
            )
          end
        end
      end

      private

      def resolved_or_standard_measure_components
        resolved_measure_components.presence || measure_components
      end

      def all_components
        measure_conditions.flat_map(&:measure_condition_components) + resolved_or_standard_measure_components
      end

      def document_components
        applicable_document_condition&.measure_condition_components
      end

      def threshold_condition_components
        applicable_threshold_condition&.measure_condition_components
      end

      def ad_valorem?
        single_component? &&
          amount_or_percentage? &&
          component.no_specific_duty?
      end

      def specific_duty?
        single_component? &&
          amount_or_percentage? &&
          component.specific_duty?
      end

      def retail_price?
        single_component? &&
          amount_or_percentage? &&
          component.retail_price?
      end

      def amount_or_percentage?
        component.amount_or_percentage?
      end

      def single_component?
        applicable_components.length == 1
      end
    end
  end
end
