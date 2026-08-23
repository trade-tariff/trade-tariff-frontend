module VatGuidancePrototype
  class ComposedJourneyRepository
    InvalidArtifact = Class.new(StandardError)
    JourneyNotFound = Class.new(StandardError)

    Journey = Data.define(
      :id,
      :kind,
      :commodity_code,
      :applicable_commodity_codes,
      :title,
      :description,
      :status,
      :review_mode,
      :production_eligible,
      :evidence_only,
      :rule_order,
      :connection_ids,
      :exhaustion_note,
      :routes,
    )

    def initialize(client: Rails.application.config.http_client_uk)
      @client = client
    end

    def all
      @all ||= commodity_journeys + notice_journeys
    end

    def find(journey_id)
      all.find { |journey| journey.id == journey_id.to_s } || raise(JourneyNotFound, journey_id)
    end

    def for_commodity(commodity_code)
      all.select { |journey| journey.applicable_commodity_codes.include?(commodity_code.to_s) }
    end

    def service_position
      artifact.fetch('service_position')
    end

    def spike_status
      artifact.fetch('spike_status')
    end

    def summary
      artifact.fetch('summary')
    end

  private

    attr_reader :client

    def artifact
      @artifact ||= begin
        response = client.get('vat_guidance_demo')
        attributes = response.body.dig('data', 'attributes')
        validate!(attributes)
        attributes
      end
    rescue Faraday::Error, NoMethodError, KeyError => e
      raise InvalidArtifact, "VAT guidance demo is unavailable: #{e.message}"
    end

    def validate!(attributes)
      unless attributes.is_a?(Hash) && attributes['ticket'] == 'AI-1146'
        raise InvalidArtifact, 'VAT guidance demo returned the wrong artifact'
      end

      status = attributes.fetch('spike_status')
      unless status['end_to_end_simulation_ready'] == true &&
          status['runtime_approved'] == false &&
          status['production_ready'] == false
        raise InvalidArtifact, 'VAT guidance demo safety status is invalid'
      end

      journeys = attributes.fetch('composed_commodity_journeys')
      unless journeys.is_a?(Array) && journeys.any? && journeys.all? { |journey| journey['production_eligible'] == false }
        raise InvalidArtifact, 'VAT guidance demo journeys are not safe for simulation'
      end

      notices = attributes.fetch('notice_journeys')
      unless notices.is_a?(Array) && notices.any? && notices.all? { |journey| safe_notice_journey?(journey) }
        raise InvalidArtifact, 'VAT guidance demo notice journeys are not safe for simulation'
      end
    end

    def safe_notice_journey?(journey)
      routes = journey['resolved_answer_paths']
      commodity_codes = journey['applicable_commodity_codes']
      journey['kind'] == 'notice' && journey['evidence_only'] == true &&
        journey['review_mode'] == 'pending_domain_review' && journey['production_eligible'] == false &&
        commodity_codes.is_a?(Array) && commodity_codes.any? && commodity_codes.all? { |code| code.match?(/\A\d{10}\z/) } &&
        routes.is_a?(Array) && routes.any? && routes.all? { |route| disconnected_notice_route?(route) }
    end

    def disconnected_notice_route?(route)
      route['additional_code'].nil? && route['measure_ids'] == [] && route['connection_ids'] == []
    end

    def commodity_journeys
      artifact.fetch('composed_commodity_journeys').map { |journey| build_commodity_journey(journey) }
    end

    def notice_journeys
      artifact.fetch('notice_journeys').map { |journey| build_notice_journey(journey) }
    end

    def build_commodity_journey(attributes)
      commodity_code = attributes.fetch('commodity_code')
      rules = attributes.fetch('rule_order')
      routes = attributes.fetch('resolved_answer_paths')
      raise InvalidArtifact, "Commodity #{commodity_code} has no composed routes" unless routes.is_a?(Array) && routes.any?

      Journey.new(
        id: commodity_code,
        kind: 'commodity',
        commodity_code:,
        applicable_commodity_codes: [commodity_code],
        title: "Commodity #{commodity_code.scan(/../).join(' ')}",
        description: "Exercises #{rules.map { |rule| rule.delete_prefix('rule-family:').humanize }.to_sentence}.",
        status: attributes.fetch('status'),
        review_mode: attributes.fetch('review_mode'),
        production_eligible: attributes.fetch('production_eligible'),
        evidence_only: false,
        rule_order: rules,
        connection_ids: attributes.fetch('connection_ids'),
        exhaustion_note: attributes.fetch('exhaustion_note'),
        routes:,
      )
    rescue KeyError => e
      raise InvalidArtifact, "Invalid commodity journey: #{e.message}"
    end

    def build_notice_journey(attributes)
      routes = attributes.fetch('resolved_answer_paths')
      raise InvalidArtifact, "Notice journey #{attributes['id']} has no answer paths" unless routes.is_a?(Array) && routes.any?

      Journey.new(
        id: attributes.fetch('id'),
        kind: attributes.fetch('kind'),
        commodity_code: nil,
        applicable_commodity_codes: attributes.fetch('applicable_commodity_codes'),
        title: attributes.fetch('title'),
        description: attributes.fetch('description'),
        status: attributes.fetch('status'),
        review_mode: attributes.fetch('review_mode'),
        production_eligible: attributes.fetch('production_eligible'),
        evidence_only: attributes.fetch('evidence_only'),
        rule_order: [],
        connection_ids: [],
        exhaustion_note: nil,
        routes:,
      )
    rescue KeyError => e
      raise InvalidArtifact, "Invalid notice journey: #{e.message}"
    end
  end
end
