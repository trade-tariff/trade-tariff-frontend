module RulesOfOriginHelper
  ROO_TAGGED_DESCRIPTIONS = %w[CC CTH CTSH EXW WO].freeze
  ROO_NON_BREAKING_HEADING = /\w+\s+\d+/

  def rules_of_origin_service_name
    TradeTariffFrontend::ServiceChooser.uk? ? 'UK' : 'EU'
  end

  def show_proofs_for_geographical_areas?(roo_schemes, measure)
    schemes_that_apply_to_geographical_area = roo_schemes&.select do |s|
      s.applies_to_geographical_area?(measure.geographical_area)
    end

    (schemes_that_apply_to_geographical_area.count <= 1) && measure.cds_proofs_of_origin(roo_schemes).any?
  end

  def rules_of_origin_schemes_intro(country_name, schemes)
    if schemes.empty?
      render 'rules_of_origin/intros/no_scheme',
             country_name:
    elsif schemes.many?
      render 'rules_of_origin/intros/multiple_schemes',
             country_name:,
             schemes:
    elsif schemes.first.countries.one?
      render 'rules_of_origin/intros/country',
             country_name:,
             scheme: schemes.first
    else
      render 'rules_of_origin/intros/trade_bloc',
             country_name:,
             scheme: schemes.first
    end
  end

  def rules_of_origin_tagged_descriptions(content)
    content.gsub(/\{\{([A-Z]+)\}\}/) do |_match|
      matched_tag = Regexp.last_match(1)

      if ROO_TAGGED_DESCRIPTIONS.include?(matched_tag)
        render "rules_of_origin/tagged_descriptions/#{matched_tag.downcase}"
      else
        ''
      end
    end
  end

  def replace_non_breaking_space(content)
    content.gsub('&nbsp;', ' ')
  end

  def remove_article_reference(content)
    content.sub(/{{(.*)}}/i, '') if content
  end

  def find_article_reference(content)
    content.scan(/{{(.*)}}/i).first&.first if content
  end

  def restrict_wrapping(content)
    safe_content = html_escape(content)

    safe_content.gsub(ROO_NON_BREAKING_HEADING) { |match|
      tag.span match, class: 'rules-of-origin__non-breaking-heading'
    }.html_safe
  end

  def rules_of_origin_form_for(current_step, *args, **kwargs, &block)
    form_for(current_step, *args, builder: GOVUKDesignSystemFormBuilder::FormBuilder,
                                  url: step_path,
                                  **kwargs) do |form|
      safe_join [
        form.govuk_error_summary,
        capture(form, &block),
        form.govuk_submit(t('rules_of_origin.steps.common.continue')),
      ], "\n"
    end
  end
end
