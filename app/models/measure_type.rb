require 'api_entity'

class MeasureType
  RENDERED_MEASURE_TYPE_DETAILS = { 'xi' => {}, 'uk' => {} }.freeze

  delegate :service_name, to: TradeTariffFrontend::ServiceChooser

  include ApiEntity

  SUPPLEMENTARY_MEASURE_TYPES = %w[109 110 111].freeze
  SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES = %w[110].freeze
  SAFEGUARD_TYPES = %w[696].freeze

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

  def supplementary?
    id.in?(SUPPLEMENTARY_MEASURE_TYPES)
  end

  def description
    translated_description || attributes['description']
  end

  def supplementary_unit_import_only?
    id.in?(SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES)
  end

  def details_text
    RENDERED_MEASURE_TYPE_DETAILS[service_name][id] ||=
      Govspeak::Document.new(
        details_markdown_text,
        sanitize: true,
      ).to_html.strip.html_safe
  end

  def safeguard?
    SAFEGUARD_TYPES.include?(id)
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
