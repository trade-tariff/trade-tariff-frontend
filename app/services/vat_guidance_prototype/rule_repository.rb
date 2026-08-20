module VatGuidancePrototype
  class RuleRepository
    class InvalidRules < StandardError; end
    class JourneyNotFound < StandardError; end

    Journey = Data.define(
      :id,
      :rule_set_id,
      :title,
      :description,
      :commodity_code,
      :commodity_codes,
      :content_version,
      :guidance_version_from,
      :guidance_version_to,
      :applicability_from,
      :applicability_to,
      :jurisdictions,
      :allowed_outcomes,
      :applicable_vat_options,
      :start_question,
      :questions,
      :sources,
      :review_status,
    ) do
      def active?(as_of:, jurisdiction:)
        reviewed? &&
          jurisdictions.include?(jurisdiction.to_s) &&
          guidance_version_from <= as_of &&
          (guidance_version_to.nil? || guidance_version_to >= as_of) &&
          applicability_from <= as_of &&
          (applicability_to.nil? || applicability_to >= as_of)
      end

      def reviewed?
        review_status == :reviewed
      end

      def generic?
        review_status == :generic
      end
    end

    Question = Data.define(:id, :text, :hint, :answers)
    Answer = Data.define(:id, :label, :next_question, :outcome, :unable_reason)
    Source = Data.define(:title, :url, :section, :reviewed_at)

    DEFAULT_PATH = Rails.root.join('config/vat_guidance_prototype/rules.yml').freeze

    class << self
      def default
        @default ||= new
      end
    end

    def initialize(path: DEFAULT_PATH)
      @path = path
    end

    def all
      @all ||= begin
        journeys = raw_rules.fetch('applicability').map do |id, mapping|
          build_journey(id, mapping)
        end

        validate_commodity_mappings!(journeys)
        journeys
      end
    end

    def find(id)
      all.find { |journey| journey.id == id.to_s } || raise(JourneyNotFound, id)
    end

    def find_by_commodity(commodity_code, as_of: Time.zone.today, jurisdiction: :uk)
      all.find do |journey|
        journey.commodity_codes.include?(commodity_code.to_s) && journey.active?(as_of:, jurisdiction:)
      end
    end

  private

    attr_reader :path

    def raw_rules
      @raw_rules ||= YAML.safe_load_file(path, aliases: false).tap do |rules|
        raise InvalidRules, 'Unsupported VAT guidance prototype schema' unless rules['schema_version'] == 3

        rules.fetch('prototype_option_catalog')
        rules.fetch('rule_sets')
        rules.fetch('applicability')
      end
    rescue KeyError, Psych::Exception => e
      raise InvalidRules, "Could not load VAT guidance prototype rules: #{e.message}"
    end

    def build_journey(id, mapping)
      rule_set_id = mapping.fetch('rule_set')
      rule_set = raw_rules.fetch('rule_sets').fetch(rule_set_id)
      variables = mapping.fetch('variables', {}).symbolize_keys
      questions = build_questions(id, rule_set.fetch('questions'), variables)
      option_keys = mapping.fetch('prototype_option_keys')
      option_catalog = raw_rules.fetch('prototype_option_catalog')
      validate_option_keys!(id, option_keys, rule_set.fetch('allowed_outcomes'), option_catalog)
      review_status = mapping.fetch('review_status').to_sym
      raise InvalidRules, "Applicability mapping #{id} is not reviewed" unless review_status == :reviewed

      journey = Journey.new(
        id: id,
        rule_set_id:,
        title: mapping.fetch('title'),
        description: mapping.fetch('description'),
        commodity_code: mapping.fetch('commodity_codes').first,
        commodity_codes: mapping.fetch('commodity_codes').map(&:to_s),
        content_version: rule_set.fetch('content_version'),
        guidance_version_from: Date.iso8601(rule_set.fetch('effective_from')),
        guidance_version_to: parse_optional_date(rule_set['effective_to']),
        applicability_from: Date.iso8601(mapping.fetch('effective_from')),
        applicability_to: parse_optional_date(mapping['effective_to']),
        jurisdictions: rule_set.fetch('jurisdictions').map(&:to_s),
        allowed_outcomes: rule_set.fetch('allowed_outcomes'),
        applicable_vat_options: option_catalog.slice(*option_keys),
        start_question: rule_set.fetch('start_question'),
        questions:,
        sources: build_sources(rule_set.fetch('sources')),
        review_status:,
      )

      validate!(journey)
      journey
    rescue KeyError, Date::Error => e
      raise InvalidRules, "Invalid applicability mapping #{id}: #{e.message}"
    end

    def build_questions(product_id, raw_questions, variables)
      raw_questions.to_h do |id, attributes|
        answers = attributes.fetch('answers').map do |answer_id, answer_attributes|
          Answer.new(
            id: answer_id,
            label: interpolate(product_id, answer_attributes.fetch('label'), variables),
            next_question: answer_attributes['next_question'],
            outcome: answer_attributes['outcome'],
            unable_reason: interpolate(product_id, answer_attributes['unable_reason'], variables),
          )
        end

        question = Question.new(
          id:,
          text: interpolate(product_id, attributes.fetch('text'), variables),
          hint: interpolate(product_id, attributes['hint'], variables),
          answers:,
        )
        [id, question]
      end
    end

    def interpolate(product_id, value, variables)
      value&.%(variables)
    rescue KeyError => e
      raise InvalidRules, "Invalid product #{product_id}: missing template variable #{e.key}"
    end

    def build_sources(raw_sources)
      raw_sources.map do |source|
        Source.new(
          title: source.fetch('title'),
          url: source.fetch('url'),
          section: source.fetch('section'),
          reviewed_at: Date.iso8601(source.fetch('reviewed_at')),
        )
      end
    end

    def parse_optional_date(value)
      Date.iso8601(value) if value.present?
    end

    def validate_option_keys!(id, option_keys, allowed_outcomes, option_catalog)
      unknown = (option_keys + allowed_outcomes).uniq - option_catalog.keys
      return if unknown.empty?

      raise InvalidRules, "Invalid applicability mapping #{id}: unknown VAT options #{unknown.join(', ')}"
    end

    def validate!(journey)
      unless journey.commodity_codes.all? { |code| code.match?(/\A\d{10}\z/) }
        raise InvalidRules, "#{journey.id} contains an invalid commodity code"
      end
      unless journey.questions.key?(journey.start_question)
        raise InvalidRules, "#{journey.id} has no start question"
      end
      if journey.applicability_to && journey.applicability_to < journey.applicability_from
        raise InvalidRules, "#{journey.id} has an invalid applicability period"
      end
      if active_to(journey) && active_to(journey) < active_from(journey)
        raise InvalidRules, "#{journey.id} has no overlap between its rule and applicability periods"
      end

      visited = validate_question!(journey, journey.start_question, [])
      unreachable = journey.questions.keys - visited
      raise InvalidRules, "#{journey.id} has unreachable questions: #{unreachable.join(', ')}" if unreachable.any?
    end

    def validate_question!(journey, question_id, ancestors)
      raise InvalidRules, "#{journey.id} contains a cycle at #{question_id}" if ancestors.include?(question_id)

      question = journey.questions.fetch(question_id) do
        raise InvalidRules, "#{journey.id} refers to missing question #{question_id}"
      end

      visited = [question_id]
      question.answers.each do |answer|
        destinations = [answer.next_question, answer.outcome, answer.unable_reason].compact
        raise InvalidRules, "#{journey.id}/#{question.id}/#{answer.id} must have one destination" unless destinations.one?

        if answer.next_question
          visited.concat(validate_question!(journey, answer.next_question, ancestors + [question_id]))
        elsif answer.outcome && !journey.allowed_outcomes.include?(answer.outcome)
          raise InvalidRules, "#{journey.id} produces unapproved VAT option #{answer.outcome}"
        end
      end

      visited.uniq
    end

    def validate_commodity_mappings!(journeys)
      mappings = journeys.flat_map do |journey|
        journey.commodity_codes.map { |code| [code, journey] }
      end
      overlaps = mappings.group_by(&:first).filter_map do |code, matches|
        journeys_for_code = matches.map(&:last)
        code if journeys_for_code.combination(2).any? { |left, right| mappings_overlap?(left, right) }
      end
      return if overlaps.empty?

      raise InvalidRules, "Commodity codes have overlapping applicability mappings: #{overlaps.join(', ')}"
    end

    def mappings_overlap?(left, right)
      return false if (left.jurisdictions & right.jurisdictions).empty?

      left_end = active_to(left) || Date.new(9999, 12, 31)
      right_end = active_to(right) || Date.new(9999, 12, 31)
      active_from(left) <= right_end && active_from(right) <= left_end
    end

    def active_from(journey)
      [journey.guidance_version_from, journey.applicability_from].max
    end

    def active_to(journey)
      [journey.guidance_version_to, journey.applicability_to].compact.min
    end
  end
end
