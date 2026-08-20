module VatGuidancePrototype
  class GenericJourneyFactory
    CONTENT_VERSION = 1
    EFFECTIVE_FROM = Date.new(2026, 7, 23)

    def initialize(commodity_code:, vat_options:, jurisdiction: :uk)
      @commodity_code = commodity_code.to_s
      @vat_options = vat_options.stringify_keys
      @jurisdiction = jurisdiction.to_s
    end

    def call
      raise ArgumentError, 'A generic journey requires more than one VAT option' unless vat_options.many?

      RuleRepository::Journey.new(
        id: "generic_#{commodity_code}",
        rule_set_id: 'generic_live_vat_options',
        title: "Commodity #{commodity_code}",
        description: 'A generic confirmation journey generated from the current tariff VAT options.',
        commodity_code:,
        commodity_codes: [commodity_code],
        content_version: CONTENT_VERSION,
        guidance_version_from: EFFECTIVE_FROM,
        guidance_version_to: nil,
        applicability_from: EFFECTIVE_FROM,
        applicability_to: nil,
        jurisdictions: [jurisdiction],
        allowed_outcomes: vat_options.keys,
        applicable_vat_options: vat_options,
        start_question: 'independent_confirmation',
        questions:,
        sources:,
        review_status: :generic,
      )
    end

  private

    attr_reader :commodity_code, :vat_options, :jurisdiction

    def questions
      {
        'independent_confirmation' => RuleRepository::Question.new(
          id: 'independent_confirmation',
          text: 'Have you confirmed which VAT treatment applies to these goods?',
          hint: 'Use current HMRC guidance or professional advice. The commodity code and tariff options alone cannot establish the correct VAT treatment.',
          answers: [
            RuleRepository::Answer.new(
              id: 'yes',
              label: 'Yes, I have confirmed the treatment',
              next_question: 'confirmed_option',
              outcome: nil,
              unable_reason: nil,
            ),
            unable_answer(
              id: 'no',
              label: 'No',
              reason: 'Check the linked HMRC guidance or obtain professional advice before choosing a VAT treatment.',
            ),
            unable_answer(
              id: 'not_sure',
              label: 'I am not sure',
              reason: 'The VAT treatment must be independently confirmed because no product-specific reviewed question set is available.',
            ),
          ],
        ),
        'confirmed_option' => RuleRepository::Question.new(
          id: 'confirmed_option',
          text: 'Which VAT treatment have you confirmed?',
          hint: 'These are the live VAT options returned by the Trade Tariff for this calculation.',
          answers: confirmed_option_answers,
        ),
      }
    end

    def confirmed_option_answers
      answers = vat_options.map do |key, label|
        RuleRepository::Answer.new(
          id: key,
          label:,
          next_question: nil,
          outcome: key,
          unable_reason: nil,
        )
      end

      answers + [
        unable_answer(
          id: 'not_sure',
          label: 'I am not sure',
          reason: 'No VAT treatment was selected because the applicable treatment has not been confirmed.',
        ),
      ]
    end

    def unable_answer(id:, label:, reason:)
      RuleRepository::Answer.new(
        id:,
        label:,
        next_question: nil,
        outcome: nil,
        unable_reason: reason,
      )
    end

    def sources
      [
        RuleRepository::Source.new(
          title: 'VAT rates on different goods and services',
          url: 'https://www.gov.uk/guidance/vat-rates-on-different-goods-and-services',
          section: 'Goods and services that may use a non-standard VAT rate',
          reviewed_at: EFFECTIVE_FROM,
        ),
        RuleRepository::Source.new(
          title: 'Paying VAT on imports from outside the UK',
          url: 'https://www.gov.uk/guidance/vat-imports-acquisitions-and-purchases-from-abroad',
          section: 'Imported goods — accounting for import VAT',
          reviewed_at: EFFECTIVE_FROM,
        ),
      ]
    end
  end
end
