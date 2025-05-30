module DutyCalculator
  module Steps
    class MeasureAmount
      STEPS_TO_REMOVE_FROM_SESSION = %w[additional_code document_code excise].freeze

      DEFAULT_MEASUREMENT_UNIT_TYPE = 'number'.freeze
      DEFAULT_HINT = 'Enter the correct value'.freeze

      # By default, all measurement types are validated as positive numbers
      MEASUREMENT_TYPE_VALIDATIONS = Hash.new do |validations, type|
        validations[type] = { 'only_positive' => true }
      end
      MEASUREMENT_TYPE_VALIDATIONS['percentage'] = { 'max' => 100, 'min' => 0 }
      MEASUREMENT_TYPE_VALIDATIONS['percentage_abv'] = { 'max' => 100, 'min' => 0 }
      MEASUREMENT_TYPE_VALIDATIONS['money'] = { 'min' => 0.001 }
      MEASUREMENT_TYPE_VALIDATIONS['discount'] = { 'min' => 0 }

      include ActiveModel::Model
      include CommodityHelper
      include Rails.application.routes.url_helpers

      attr_reader :applicable_measure_units

      validates_each :answers do |record, _attr, _value|
        validation_messages = I18n.t('activemodel.errors.models.duty_calculator/steps/measure_amount.attributes.answers')

        record.applicable_measure_units.each do |key, values|
          type = values['measurement_unit_type'].presence || DEFAULT_MEASUREMENT_UNIT_TYPE
          key = key.downcase
          value = record.public_send(key.downcase)
          hint = values['unit_hint'] || DEFAULT_HINT

          record.errors.add(key, "#{validation_messages[:blank]} #{values['unit_hint']}") if value.blank?

          value = Float(value)

          MEASUREMENT_TYPE_VALIDATIONS[type].each do |validation, validation_value|
            case validation
            when 'only_positive'
              record.errors.add(key, "#{validation_messages[:greater_than]} #{hint}") unless value.positive?
            when 'max'
              record.errors.add(key, "#{validation_messages[:max]} #{validation_value}. #{hint}") if value > validation_value
            when 'min'
              record.errors.add(key, "#{validation_messages[:min]} #{validation_value}. #{hint}") if value < validation_value
            end
          end
        rescue ArgumentError, TypeError
          record.errors.add(key, "#{validation_messages[:not_a_number]} #{values['unit_hint']}")
        end
      end

      def initialize(attributes)
        @attributes = attributes
        @answers = attributes['measure_amount']
        @applicable_measure_units = attributes['applicable_measure_units']
        @applicable_measure_units.each_key do |key|
          key = key.downcase

          define_singleton_method(key) do
            instance_variable_get("@#{key}") || user_session.measure_amount[key]
          end

          define_singleton_method("#{key}=") do |value|
            instance_variable_set("@#{key}", value)
          end
        end

        @answers.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      def save!
        user_session.measure_amount = answers if answers.present?
      end

      def next_step_path
        return additional_codes_path(applicable_measure_type_ids.first) if applicable_additional_codes?
        return document_codes_path(document_codes_applicable_measure_type_ids.first) if applicable_document_codes?
        return excise_path(applicable_excise_measure_type_ids.first) if applicable_excise_additional_codes?

        return vat_path if applicable_vat_options.keys.count > 1

        confirm_path
      end

      def previous_step_path
        customs_value_path
      end

      def self.id
        name.split('::').last.underscore
      end

      private

      attr_reader :answers, :attributes

      def user_session
        UserSession.get
      end
    end
  end
end
