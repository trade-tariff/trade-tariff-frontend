class MeasureType
  RENDERED_MEASURE_TYPE_DETAILS = { 'xi' => {}, 'uk' => {} }.freeze

  delegate :service_name, to: TradeTariffFrontend::ServiceChooser

  include ApiEntity

  enum :measure_component_applicable_code, {
    duties_permitted: [0],
    duties_mandatory: [1],
    duties_not_permitted: [2],
  }

  attr_accessor :id,
                :measure_component_applicable_code,
                :measure_type_series_id,
                :semantic_roles

  attr_writer :description, :geographical_area_id

  def description
    translated_description || attributes['description']
  end

  def details_text
    RENDERED_MEASURE_TYPE_DETAILS[service_name][id] ||=
      Govspeak::Document.new(
        details_markdown_text,
        sanitize: true,
      ).to_html.strip.html_safe
  end

  def abbreviation
    return 'Prohibition' if description.scan(/Prohibition/i).present?
    return 'Restriction' if description.scan(/Restriction/i).present?

    'Control'
  end

  def mfn_no_authorized_use?
    semantic_roles.include?('mfn_no_authorized_use')
  end

  def provides_unit_context?
    semantic_roles.include?('provides_unit_context')
  end

  def safeguard?
    semantic_roles.include?('safeguard')
  end

  def supplementary?
    semantic_roles.include?('supplementary')
  end

  def supplementary_unit_import_only?
    semantic_roles.include?('supplementary_unit_import_only')
  end

  def cds_proofs_of_origin?
    semantic_roles.include?('cds_proofs_of_origin')
  end

  def prohibitive?
    semantic_roles.include?('prohibitive')
  end

  private

  def translated_description
    I18n.t("measure_type_descriptions.#{geographical_area_id}.#{id}", default: nil)
  end

  def geographical_area_id
    if casted_by.present?
      casted_by.geographical_area.id
    else
      @geographical_area_id
    end
  end

  def details_markdown_text
    if File.exist?(details_markdown_file)
      File.read(details_markdown_file)
    end
  end

  def details_markdown_file
    "db/measure_type_detail_texts/#{TradeTariffFrontend::ServiceChooser.service_name}/#{id}.md"
  end
end
