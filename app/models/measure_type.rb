require 'api_entity'

class MeasureType
  RENDERED_MEASURE_TYPE_DETAILS = { 'xi' => {}, 'uk' => {} }.freeze

  delegate :service_name, to: TradeTariffFrontend::ServiceChooser

  include ApiEntity

  enum :id, {
    excise: %w[306],
    mfn_no_authorized_use: %w[103],
    provides_unit_context: %w[103 105 141 142 145 106 122 123 143 146],
    safeguard: %w[696],
    supplementary: %w[109 110 111],
    supplementary_unit_import_only: %w[110],
    cds_proofs_of_origin: %w[141 142 143 145 146 147],
  }

  enum :measure_component_applicable_code, {
    duties_permitted: [0],
    duties_mandatory: [1],
    duties_not_permitted: [2],
  }

  enum :measure_type_series_id, {
    prohibitive: %w[A B],
  }

  attr_accessor :id, :measure_component_applicable_code, :measure_type_series_id
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
