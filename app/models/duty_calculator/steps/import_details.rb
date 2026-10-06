module DutyCalculator
  module Steps
    # Asks for the import date, destination and country of origin on one page.
    # Answers are stored under the same session keys as the separate
    # import date, import destination and country of origin steps.
    class ImportDetails < Steps::Base
      include ActiveRecord::AttributeAssignment

      DEPENDENT_STEPS = (Steps::ImportDate::STEPS_TO_REMOVE_FROM_SESSION + %w[meursing_additional_code]).freeze

      attribute :import_date, :date
      attribute 'import_date(3i)', :string
      attribute 'import_date(2i)', :string
      attribute 'import_date(1i)', :string
      attribute :import_destination, :string
      attribute :country_of_origin, :string

      validate :import_date_validation
      validates :import_destination, presence: true
      validates :country_of_origin, presence: true
      validate :country_of_origin_in_destination_list

      def initialize(attributes = {})
        super(without_invalid_date(attributes))
      end

      # The same country lists as the existing country of origin page:
      # the UK service list for GB and the XI service list for Northern Ireland.
      def self.country_options(import_destination)
        service = import_destination == 'XI' ? :xi : :uk

        Api::GeographicalArea.list_countries(service)
          .sort_by(&:description)
          .map { |country| Option.new(id: country.id, name: country.long_description) }
      end

      # Each list is fetched once per request and shared by the view and validation.
      def country_options_for(destination)
        destination = destination == 'XI' ? 'XI' : 'UK'
        @country_options ||= {}
        @country_options[destination] ||= self.class.country_options(destination)
      end

      def country_lists
        %w[UK XI].index_with { |destination| country_options_for(destination) }
      end

      def import_date
        date = super || user_session.import_date || Time.zone.today
        date.is_a?(Date) ? date : Date.parse(date.to_s)
      rescue ArgumentError
        Time.zone.today
      end

      def import_destination
        super || user_session.import_destination
      end

      def country_of_origin
        super || user_session.origin_country_code
      end

      def save!
        @changed = changed_from_session?
        user_session.remove_step_ids(DEPENDENT_STEPS) if @changed

        user_session.import_date = input_date.strftime('%Y-%m-%d')
        user_session.import_destination = import_destination
        user_session.commodity_source = import_destination == 'XI' ? 'xi' : 'uk'
        save_country_of_origin
        # Set again by the controller for the Northern Ireland routes that need them.
        user_session.trade_defence = nil
        user_session.zero_mfn_duty = nil
      end

      def changed?
        @changed
      end

      # Uses the same route rules as the country of origin step.
      def other_country_of_origin?
        import_destination == 'XI' &&
          country_of_origin != 'GB' &&
          !Api::GeographicalArea.eu_member?(country_of_origin)
      end

      def next_step_path
        Steps::CountryOfOrigin.new(
          {
            country_of_origin: user_session.country_of_origin,
            other_country_of_origin: user_session.other_country_of_origin,
          },
          trade_defence: user_session.trade_defence,
          zero_mfn_duty: user_session.zero_mfn_duty,
        ).next_step_path
      end

      def previous_step_path
        return confirm_path if user_session.return_to_confirm

        commodity_path(user_session.commodity_code)
      end

    private

      def save_country_of_origin
        if other_country_of_origin?
          user_session.country_of_origin = 'OTHER'
          user_session.other_country_of_origin = country_of_origin
        else
          user_session.country_of_origin = country_of_origin
          user_session.other_country_of_origin = nil
        end
      end

      def changed_from_session?
        user_session.import_date != input_date ||
          user_session.import_destination != import_destination ||
          user_session.origin_country_code != country_of_origin
      end

      def import_date_validation
        return if input_date.present? && input_date >= Date.new(2021, 1, 1)

        errors.add(:import_date, :invalid_date)
      end

      def country_of_origin_in_destination_list
        return if country_of_origin.blank? || import_destination.blank?
        return if country_options_for(import_destination).any? { |option| option.id == country_of_origin }

        errors.add(:country_of_origin, :blank)
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

      # An impossible date (for example 31 2 2026) is dropped so that
      # validation reports it in the same way as a missing date.
      def without_invalid_date(attributes)
        attributes = HashWithIndifferentAccess.new(attributes.to_h)
        date_parts = %w[import_date(1i) import_date(2i) import_date(3i)]
        return attributes if attributes.slice(*date_parts).empty? || valid_date?(attributes)

        attributes.except(*date_parts)
      end
    end
  end
end
