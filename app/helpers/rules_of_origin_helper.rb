module RulesOfOriginHelper
  def rules_of_origin_service_name
    TradeTariffFrontend::ServiceChooser.uk? ? 'UK' : 'EU'
  end

  def rules_of_origin_schemes_intro(country_name, schemes)
    if schemes.empty?
      return render 'measures/rules_of_origin_intro_no_scheme',
                    country_name: country_name
    end

    schemes_intros = schemes.map do |scheme|
      partial = scheme.countries.length > 1 ? 'bloc' : 'country'

      render "measures/rules_of_origin_intro_#{partial}",
             country_name: country_name,
             scheme: scheme
    end

    safe_join schemes_intros, "\n\n"
  end
end
