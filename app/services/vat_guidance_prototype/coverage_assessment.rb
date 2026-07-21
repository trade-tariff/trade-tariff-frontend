module VatGuidancePrototype
  class CoverageAssessment
    Result = Data.define(:status, :journey, :vat_options) do
      def guided?
        status == :guided
      end

      def not_eligible?
        status == :not_eligible
      end
    end

    def initialize(
      commodity_code:,
      vat_options:,
      repository: RuleRepository.default,
      generic_journey_factory: GenericJourneyFactory,
      as_of: Time.zone.today,
      jurisdiction: :uk
    )
      @commodity_code = commodity_code.to_s
      @vat_options = vat_options.stringify_keys
      @repository = repository
      @generic_journey_factory = generic_journey_factory
      @as_of = as_of
      @jurisdiction = jurisdiction
    end

    def call
      return result(:not_eligible) unless vat_options.many?

      journey = repository.find_by_commodity(commodity_code, as_of:, jurisdiction:)
      journey ||= generic_journey_factory.new(
        commodity_code:,
        vat_options:,
        jurisdiction:,
      ).call

      result(:guided, journey:)
    end

  private

    attr_reader :commodity_code, :vat_options, :repository, :generic_journey_factory, :as_of, :jurisdiction

    def result(status, journey: nil)
      Result.new(status:, journey:, vat_options:)
    end
  end
end
