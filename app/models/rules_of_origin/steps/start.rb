module RulesOfOrigin
  module Steps
    class Start < Base
      delegate :service_choices, to: :class

      attribute :service
      attribute :country_code
      attribute :commodity_code

      validates :service, presence: true, inclusion: { in: :service_choices }
      validates :country_code, presence: true
      validates :commodity_code, presence: true, format: %r{\A\d{10}\z}

      class << self
        def service_choices
          @service_choices ||= TradeTariffFrontend::ServiceChooser.service_choices.keys
        end
      end

      def save!
        self.service = TradeTariffFrontend::ServiceChooser.service_name

        @store.purge!

        super || raise(RecordInvalid, self)
      end

      class RecordInvalid < StandardError
        def initialize(record)
          super record.errors.full_messages.join(', ')
        end
      end
    end
  end
end
