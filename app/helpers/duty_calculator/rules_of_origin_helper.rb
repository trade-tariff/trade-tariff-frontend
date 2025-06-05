module DutyCalculator
  module RulesOfOriginHelper
    ROO_TAGGED_DESCRIPTIONS = %w[CC CTH CTSH EXW WO].freeze
    ROO_NON_BREAKING_HEADING = /\w+\s+\d+/

    def scheme_for(option, schemes)
      schemes.find { |scheme| scheme.scheme_code == option.scheme_code }
    end

    def rules_of_origin_tagged_descriptions(content)
      content.gsub(/\{\{([A-Z]+)\}\}/) do |_match|
        matched_tag = Regexp.last_match(1)

        if ROO_TAGGED_DESCRIPTIONS.include?(matched_tag)
          render "steps/duty/calculations/rules_of_origin/tagged_descriptions/#{matched_tag.downcase}"
        else
          ''
        end
      end
    end

    def replace_non_breaking_space(content)
      content.gsub('&nbsp;', ' ')
    end

    def restrict_wrapping(content)
      safe_content = html_escape(content)

      safe_content = safe_content.gsub(ROO_NON_BREAKING_HEADING) do |match|
        tag.span match, class: 'rules-of-origin__non-breaking-heading'
      end

      safe_content.html_safe
    end
  end
end
