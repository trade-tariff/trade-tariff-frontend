module DutyCalculator
  module MeursingAdditionalCodeHelper
    def meursing_lookup_hint_text
      hint_text = t(
        'meursing_additional_code.hint_text',
        link: meursing_lookup_link,
      )

      sanitize(
        hint_text,
        tags: %w[p a],
        attributes: %w[class target rel href],
      )
    end

  private

    def meursing_lookup_link
      link_to(
        t('meursing_additional_code.link_text'),
        meursing_lookup_step_path(:start),
        class: 'govuk-link',
        target: '_blank',
        rel: 'noopener norefferer',
      )
    end
  end
end
