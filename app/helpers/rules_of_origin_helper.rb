module RulesOfOriginHelper
  ROO_TAGGED_DESCRIPTIONS = %w[CC CTH CTSH EXW WO].freeze

  def rules_of_origin_service_name
    TradeTariffFrontend::ServiceChooser.uk? ? 'UK' : 'EU'
  end

  def rules_of_origin_schemes_intro(country_name, schemes)
    if schemes.empty?
      return render('rules_of_origin/intro_no_scheme', country_name: country_name)
    end

    schemes_intros = schemes.map do |scheme|
      partial = scheme.countries.length > 1 ? 'trade_bloc' : 'country'

      render "rules_of_origin/intro_#{partial}",
             country_name: country_name,
             scheme: scheme
    end

    safe_join schemes_intros, "\n\n"
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
end
