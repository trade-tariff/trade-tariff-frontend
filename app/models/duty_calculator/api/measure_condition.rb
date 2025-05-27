module DutyCalculator
  module Api
    class MeasureCondition < Api::Base
      REQUIREMENT_OPERATOR_MAPPINGS = {
        '=<' => '<=',
        '=>' => '>=',
        '>' => '>',
      }.freeze

      attributes :id,
                 :action,
                 :action_code,
                 :condition,
                 :condition_code,
                 :condition_duty_amount,
                 :condition_measurement_unit_code,
                 :condition_measurement_unit_qualifier_code,
                 :condition_monetary_unit_code,
                 :document_code,
                 :certificate_description,
                 :duty_expression,
                 :monetary_unit_abbreviation,
                 :requirement,
                 :requirement_operator

      has_many :measure_condition_components, MeasureConditionComponent

      enum :action_code, {
        stopping: [
          '08', # Declared subheading not allowed
        ],
        applicable: [
          '01', # Apply the amount of the action (see components)
          '24', # Entry into free circulation allowed
          '25', # Export allowed
          '26', # Import allowed
          '27', # Apply the mentioned duty
          '28', # Declared subheading allowed
          '29', # Import/export allowed after control
          '34', # Apply exemption/reduction of the anti-dumping duty
          '36', # Apply export refund
        ],
        not_applicable: [
          '04',  # 'The entry into free circulation is not allowed'
          '05',  # 'Export is not allowed'
          '06',  # 'Import is not allowed'
          '07',  # 'Measure not applicable'
          '08',  # 'Declared subheading not allowed'
          '09',  # 'Import/export not allowed after control'
          '10',  # 'Declaration to be corrected - box 33, 37, 38, 41 or 46 incorrect'
          '16',  # 'Export refund not applicable'
          '30',  # 'Suspicious case'
        ],
      }

      enum :condition_code, {
        condition_code_supported: [
          'A', # Presentation of an anti-dumping/countervailing document
          'B', # Presentation of a certificate/licence/document
          'C', # Presentation of a certificate/licence/document
          'E', # The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document
          'H', # Presentation of a certificate/licence/document
          'I', # The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document
        ],
      }

      def requirement_operator
        REQUIREMENT_OPERATOR_MAPPINGS[attributes[:requirement_operator]] || attributes[:requirement_operator]
      end

      def expresses_document?
        attributes[:document_code].present? && condition_code_supported?
      end

      def expresses_unit?
        condition_measurement_unit_code.present?
      end

      def lpa_based?
        measure_condition_component_units.include?('LPA')
      end

      def asvx_based?
        measure_condition_component_units.include?('ASVX')
      end

      def document_code
        return attributes[:document_code] if attributes[:document_code].present?

        'None'
      end

      def certificate_description
        return "#{document_code} - #{attributes[:certificate_description]}" unless document_code == 'None'

        'None of the above'
      end

      def condition_measurement_unit
        "#{condition_measurement_unit_code}#{condition_measurement_unit_qualifier_code}" if expresses_unit?
      end

      private

      def measure_condition_component_units
        @measure_condition_component_units ||= measure_condition_components.map(&:unit).compact
      end
    end
  end
end
