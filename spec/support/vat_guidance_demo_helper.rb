module VatGuidanceDemoHelper
  def vat_guidance_demo_response
    {
      data: {
        id: 'ai-1146',
        type: 'vat_guidance_demo',
        attributes: {
          schema_version: 1,
          ticket: 'AI-1146',
          source_artifact_sha256: 'a' * 64,
          service_position: "The service guides using the trader's own answers and presents candidate VAT treatments for review.",
          spike_status: {
            end_to_end_simulation_ready: true,
            hmrc_demo_ready: false,
            production_ready: false,
            runtime_approved: false,
          },
          summary: {
            answer_paths: 53,
            pinned_measure_proposals: 12,
            composed_spike_commodities: 11,
          },
          composed_commodity_journeys: [{
            commodity_code: '2005202000',
            status: 'spike_simulation_complete',
            review_mode: 'synthetic_spike_fixture',
            production_eligible: false,
            rule_order: ['rule-family:potato-crisps-exception'],
            connection_ids: ['connection-proposal:test'],
            exhaustion_note: {
              standard_by_default_permitted_after_all_rules_decline: true,
            },
            resolved_answer_paths: [
              {
                id: 'composed-route:standard',
                steps: [vat_guidance_demo_step('yes', 'Yes')],
                resolution: 'explicit_guidance',
                treatment: 'standard',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
              },
              {
                id: 'composed-route:zero',
                steps: [
                  vat_guidance_demo_step('no', 'No'),
                  {
                    question_id: 'packaged-ready',
                    question: 'Is the product packaged and ready to eat?',
                    answer_id: 'yes',
                    answer: 'Yes',
                    evidence: vat_guidance_demo_evidence,
                  },
                ],
                resolution: 'synthetic_spike_rule_connections',
                treatment: 'zero',
                additional_code: 'VATZ',
                measure_ids: ['-1012550499'],
                connection_ids: ['connection-proposal:test'],
              },
            ],
          }],
          notice_journeys: [{
            id: 'notice-701-14-food-exceptions',
            kind: 'notice',
            applicable_commodity_codes: %w[2005202000 2008939120 2008979890],
            title: 'VAT Notice 701/14 — food exceptions',
            description: 'Exercises the standalone food-exception path from VAT Notice 701/14.',
            status: 'spike_evidence_only',
            review_mode: 'pending_domain_review',
            production_eligible: false,
            evidence_only: true,
            resolved_answer_paths: [
              {
                id: 'answer-path:70114-zero-food',
                steps: [vat_guidance_food_exception_step('no', 'No')],
                resolution: 'evidence_only_notice_comparison',
                treatment: 'zero',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
                terminal_evidence: vat_guidance_food_evidence,
              },
              {
                id: 'answer-path:70114-standard-food',
                steps: [vat_guidance_food_exception_step('yes', 'Yes')],
                resolution: 'evidence_only_notice_comparison',
                treatment: 'standard',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
                terminal_evidence: vat_guidance_food_evidence,
              },
            ],
          }, {
            id: 'notice-709-1-catering-reference-expanded',
            kind: 'notice',
            applicable_commodity_codes: %w[2005202000 2008939120 2008979890],
            title: 'VAT Notice 709/1 — catering and food exceptions',
            description: 'Exercises the reference-expanded catering path and its VAT Notice 701/14 food-exception follow-up.',
            status: 'spike_evidence_only',
            review_mode: 'pending_domain_review',
            production_eligible: false,
            evidence_only: true,
            resolved_answer_paths: [
              {
                id: 'answer-path:7091-standard-catering',
                steps: [vat_guidance_notice_step('yes', 'Yes')],
                resolution: 'evidence_only_notice_comparison',
                treatment: 'standard',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
                terminal_evidence: vat_guidance_notice_evidence,
              },
              {
                id: 'answer-path:7091-zero-food',
                steps: [
                  vat_guidance_notice_step('no', 'No'),
                  vat_guidance_food_exception_step('no', 'No'),
                ],
                resolution: 'evidence_only_notice_comparison',
                treatment: 'zero',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
                terminal_evidence: vat_guidance_food_evidence,
              },
              {
                id: 'answer-path:7091-standard-food-exception',
                steps: [
                  vat_guidance_notice_step('no', 'No'),
                  vat_guidance_food_exception_step('yes', 'Yes'),
                ],
                resolution: 'evidence_only_notice_comparison',
                treatment: 'standard',
                additional_code: nil,
                measure_ids: [],
                connection_ids: [],
                terminal_evidence: vat_guidance_food_evidence,
              },
            ],
          }],
        },
      },
    }.deep_stringify_keys
  end

  def stub_vat_guidance_demo(response = vat_guidance_demo_response)
    stub_api_request('vat_guidance_demo', backend: 'uk').to_return(
      status: 200,
      headers: { 'content-type' => 'application/json' },
      body: JSON.generate(response),
    )
  end

private

  def vat_guidance_demo_step(answer_id, answer)
    {
      question_id: 'catering',
      question: 'Is the product supplied in the course of catering?',
      answer_id:,
      answer:,
      evidence: vat_guidance_demo_evidence,
    }
  end

  def vat_guidance_demo_evidence
    {
      quote: 'You must always standard rate food supplied in the course of catering.',
      node_id: 'document:/guidance/food-products-and-vat-notice-70114#food-supplied-in-the-course-of-catering',
    }
  end

  def vat_guidance_notice_step(answer_id, answer)
    {
      question_id: 'course-of-catering-expanded',
      question: 'Is the supply made in the course of catering?',
      answer_id:,
      answer:,
      evidence: vat_guidance_notice_evidence,
    }
  end

  def vat_guidance_food_exception_step(answer_id, answer)
    {
      question_id: 'food-standard-exception',
      question: 'Does the item fall within a standard-rated food exception identified by VAT Notice 701/14?',
      answer_id:,
      answer:,
      evidence: vat_guidance_food_evidence,
    }
  end

  def vat_guidance_notice_evidence
    {
      quote: 'Other supplies are standard-rated because they’re made in the course of catering.',
      node_id: 'document:/guidance/catering-takeaway-food-and-vat-notice-7091#information-in-this-notice',
    }
  end

  def vat_guidance_food_evidence
    {
      quote: 'Most food of a kind used for human consumption is zero-rated. There are, however, some exceptions.',
      node_id: 'document:/guidance/food-products-and-vat-notice-70114#food-not-supplied-in-the-course-of-catering',
    }
  end
end

RSpec.configure do |config|
  config.include VatGuidanceDemoHelper
end
