class GroupedMeasuresPresenter
  attr_reader :uk_declarable, :xi_declarable, :rules_of_origin_schemes, :search, :service_chooser

  def initialize(uk_declarable:, xi_declarable:, rules_of_origin_schemes: [], search: nil, service_chooser: TradeTariffFrontend::ServiceChooser)
    @uk_declarable = uk_declarable
    @xi_declarable = xi_declarable
    @rules_of_origin_schemes = rules_of_origin_schemes
    @search = search
    @service_chooser = service_chooser
  end

  def uk_sections
    return [] if uk_import_measures.blank?

    sections = []

    if uk_import_measures.import_controls.present?
      sections << {
        caption: 'Import controls',
        collection: sorted_by_key(uk_import_measures.import_controls),
        css_id: 'uk_import_controls',
        declarable: uk_declarable,
        hide_duty_rate: true,
        search:,
        show_stw_text: true,
        anchor: 'import',
        roo_schemes: rules_of_origin_schemes,
        information: I18n.t('tabs.measures.import_controls_uk'),
      }
    end

    if uk_import_measures.customs_duties.present?
      sections << {
        caption: 'Import duties',
        collection: sorted_by_key(uk_import_measures.customs_duties),
        css_id: 'import_duties',
        declarable: uk_declarable,
        show_duty_calculator: uk_declarable.calculate_duties?,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures.quotas.present?
      sections << {
        caption: 'Quotas',
        information: I18n.t('tabs.measures.quotas_information_html'),
        collection: sorted_by_key(uk_import_measures.quotas),
        css_id: 'quotas',
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures.trade_remedies.present?
      sections << {
        caption: 'Trade remedies, safeguards and retaliatory duties',
        collection: sorted_by_key(uk_import_measures.trade_remedies),
        css_id: 'trade_remedies',
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures.suspensions.present?
      sections << {
        caption: 'Suspensions',
        collection: sorted_by_key(uk_import_measures.suspensions),
        css_id: 'suspensions',
        uk_declarable:,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures.credibility_checks.present?
      sections << {
        caption: 'Credibility checks',
        collection: sorted_by_key(uk_import_measures.credibility_checks),
        css_id: 'credibility_checks',
        hide_duty_rate: true,
        credibility_checks: true,
        uk_declarable:,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures.vat_excise.present?
      sections << {
        caption: 'Import VAT and excise',
        collection: sorted_by_key(uk_import_measures.vat_excise),
        css_id: 'vat_excise',
        uk_declarable:,
        vat_excise: true,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    sections
  end

  def xi_sections
    sections = []

    if xi_import_measures.customs_duties.present?
      sections << {
        caption: 'Import duties',
        collection: sorted_by_key(xi_import_measures.customs_duties),
        css_id: 'import_duties',
        declarable: xi_declarable,
        show_duty_calculator: xi_declarable.calculate_duties?,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if xi_import_measures.trade_remedies.present?
      sections << {
        caption: 'Trade remedies, safeguards and retaliatory duties',
        collection: sorted_by_key(xi_import_measures.trade_remedies),
        css_id: 'trade_remedies',
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if xi_import_measures.suspensions.present?
      sections << {
        caption: 'Suspensions',
        collection: sorted_by_key(xi_import_measures.suspensions),
        css_id: 'suspensions',
        declarable: xi_declarable,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if xi_import_measures.credibility_checks.present?
      sections << {
        caption: 'Credibility checks',
        collection: sorted_by_key(xi_import_measures.credibility_checks),
        css_id: 'credibility_checks',
        credibility_checks: true,
        hide_duty_rate: true,
        xi_declarable:,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures&.vat_excise.present?
      sections << {
        caption: 'Import VAT and excise',
        collection: sorted_by_key(uk_import_measures.vat_excise),
        css_id: 'vat_excise',
        uk_declarable:,
        vat_excise: true,
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if xi_import_measures.import_controls.present?
      sections << {
        caption: 'EU import controls',
        collection: sorted_by_key(xi_import_measures.import_controls),
        hide_duty_rate: true,
        css_id: 'xi_import_controls',
        roo_schemes: rules_of_origin_schemes,
      }
    end

    if uk_import_measures&.import_controls.present?
      sections << {
        caption: 'UK import controls',
        collection: sorted_by_key(uk_import_measures.import_controls),
        hide_duty_rate: true,
        css_id: 'uk_import_controls',
        roo_schemes: rules_of_origin_schemes,
      }
    end

    sections
  end

  def navigation_items
    service_chooser.uk? ? uk_navigation_items : xi_navigation_items
  end

  def uk_navigation_items
    return [] if uk_import_measures.blank?

    items = []
    items << { text: 'Import controls', anchor: '#uk_import_controls' } if uk_import_measures.import_controls.present?
    items << { text: 'Import duties', anchor: '#import_duties' } if uk_import_measures.customs_duties.present?
    items << { text: 'Quotas', anchor: '#quotas' } if uk_import_measures.quotas.present?
    items << { text: 'Trade remedies, safeguards and retaliatory duties', anchor: '#trade_remedies' } if uk_import_measures.trade_remedies.present?
    items << { text: 'Suspensions', anchor: '#suspensions' } if uk_import_measures.suspensions.present?
    items << { text: 'Credibility checks', anchor: '#credibility_checks' } if uk_import_measures.credibility_checks.present?
    items << { text: 'Import VAT and excise', anchor: '#vat_excise' } if uk_import_measures.vat_excise.present?
    items
  end

  def xi_navigation_items
    items = []
    items << { text: 'Import duties', anchor: '#import_duties' } if xi_import_measures.customs_duties.present?
    items << { text: 'Trade remedies, safeguards and retaliatory duties', anchor: '#trade_remedies' } if xi_import_measures.trade_remedies.present?
    items << { text: 'Suspensions', anchor: '#suspensions' } if xi_import_measures.suspensions.present?
    items << { text: 'Credibility checks', anchor: '#credibility_checks' } if xi_import_measures.credibility_checks.present?
    items << { text: 'Import VAT and excise', anchor: '#vat_excise' } if uk_import_measures&.vat_excise.present?
    items << { text: 'EU import controls', anchor: '#xi_import_controls' } if xi_import_measures.import_controls.present?
    items << { text: 'UK import controls', anchor: '#uk_import_controls' } if uk_import_measures&.import_controls.present?
    items
  end

  def show_meursing_form?
    return false if xi_declarable.blank?

    xi_import_measures.customs_duties.present? && xi_declarable.meursing_code?
  end

  private

  def uk_import_measures
    @uk_import_measures ||= uk_declarable&.import_measures
  end

  def xi_import_measures
    @xi_import_measures ||= xi_declarable.import_measures
  end

  def sorted_by_key(measures)
    measures.sort_by(&:key)
  end
end
