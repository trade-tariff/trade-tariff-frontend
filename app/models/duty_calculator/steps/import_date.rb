module DutyCalculator
  module Steps
    class ImportDate < Steps::Base
      include ActiveRecord::AttributeAssignment

      STEPS_TO_REMOVE_FROM_SESSION = %w[
        import_destination
        country_of_origin
        trader_scheme
        final_use
        certificate_of_origin
        annual_turnover
        planned_processing
        document_code
        excise
        vat
      ].freeze

      attribute :import_date, :date

      attribute 'import_date(3i)', :string
      attribute 'import_date(2i)', :string
      attribute 'import_date(1i)', :string

      validate :import_date_validation

      def initialize(attributes = {})
        check_attributes_validity(attributes)
        super
      end

      def import_date
        super || user_session.import_date || Time.zone.now.strftime('%Y-%m-%d')
      end

      def save!
        user_session.import_date = input_date.strftime('%Y-%m-%d')
      end

      def next_step_path
        import_destination_path
      end

    private

      def import_date_validation
        return if input_date.present? && input_date >= Date.new(2021, 1, 1)

        errors.add(:import_date, :invalid_date)
      end

      def valid_date?(attributes)
        Date.civil(
          attributes['import_date(1i)'].to_i,
          attributes['import_date(2i)'].to_i,
          attributes['import_date(3i)'].to_i,
        )
      rescue ArgumentError
        false
      end

      def input_date
        attributes['import_date']
      end

      def check_attributes_validity(attributes = {})
        return if attributes.empty? || valid_date?(attributes)

        errors.add(:import_date, :invalid_date)

        attributes.delete 'import_date(1i)'
        attributes.delete 'import_date(2i)'
        attributes.delete 'import_date(3i)'
      end
    end
  end
end
