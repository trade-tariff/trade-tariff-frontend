module RulesOfOrigin
  class WizardStore < ::WizardSteps::Store
    PREFIX = 'rules_of_origin-'.freeze
    MAX_JOURNEYS = 5

    class << self
      def gc_store_data(backing_store)
        backing_store.keys
                     .select { |k| k.start_with? PREFIX }
                     .sort_by { |k| backing_store[k]['modified'] || '2022-01-01T00:00:00Z' }
                     .reverse
                     .slice(MAX_JOURNEYS..)
                     &.each { |k| backing_store.delete k }
      end
    end

    def initialize(backing_store, key)
      @backing_store = backing_store
      @backing_store["#{PREFIX}#{key}"] ||= {}

      super @backing_store["#{PREFIX}#{key}"]
    end

    def persist(attributes)
      super(attributes.merge('modified' => Time.zone.now.iso8601)).tap do
        self.class.gc_store_data(@backing_store)
      end
    end
  end
end
