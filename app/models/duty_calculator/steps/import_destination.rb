module DutyCalculator
  module Steps
    class ImportDestination < Steps::Base
      # We call England, Scotland or Wales (GB) as UK beacuse that is how we named the backend source when the service is the UK version
      OPTIONS = [
        OpenStruct.new(id: 'UK', name: 'England, Scotland or Wales (GB)'),
        OpenStruct.new(id: 'XI', name: 'Northern Ireland'),
      ].freeze

      STEPS_TO_REMOVE_FROM_SESSION = %w[
        country_of_origin
        trader_scheme
        final_use
        certificate_of_origin
        annual_turnover
        planned_processing
        document_code
        excise
      ].freeze

      attribute :import_destination, :string

      validates :import_destination, presence: true

      def import_destination
        super || user_session.import_destination
      end

      def save!
        user_session.import_destination = import_destination

        update_commodity_source
      end

      def next_step_path
        country_of_origin_path
      end

      def previous_step_path
        import_date_path(commodity_code: user_session.commodity_code)
      end

      private

      def update_commodity_source
        user_session.commodity_source = (import_destination == 'XI' ? 'xi' : 'uk')
      end
    end
  end
end
