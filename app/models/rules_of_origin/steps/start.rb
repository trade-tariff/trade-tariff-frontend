module RulesOfOrigin
  module Steps
    class Start < Base
      attribute :service
      attribute :country_code
      attribute :commodity_code

      validates :service, presence: true, inclusion: { in: :current_service }
      validates :country_code, presence: true
      validates :commodity_code, presence: true, format: %r{\A\d{10}\z}

      def save!
        @store.purge!

        super || raise(RecordInvalid, self)
      end

      class RecordInvalid < StandardError
        def initialize(record)
          super record.errors.full_messages.join(', ')
        end
      end

    private

      def current_service
        [TradeTariffFrontend::ServiceChooser.service_name]
      end
    end
  end
end
