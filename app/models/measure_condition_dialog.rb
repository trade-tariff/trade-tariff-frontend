# Because much of the content that comes back from the raw CDS data is pretty difficult
# to understand, this class replaces or augments it with curated, custom content in the
# conditions dialog window.
class MeasureConditionDialog
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :options

  DEFAULT_CONFIG_ENTRY = {
    content_file: nil,
    overwrite: nil,
  }.freeze

  CONFIG_FILE_NAME = 'db/measure_condition_dialog_config.yaml'.freeze

  class << self
    def build(declarable, measure)
      config = config_for(
        declarable.goods_nomenclature_item_id,
        measure.additional_code.code,
        measure.measure_type.id,
      )

      overwrite = config['overwrite']
      content_file = config['content_file']

      options = if content_file.present?
                  if overwrite
                    { partial: "measures/measure_condition_replacement_modals/#{content_file}" }
                  else
                    {
                      partial: 'measures/measure_condition_modal_augmented',
                      locals: { modal_content_file: "measures/measure_condition_replacement_modals/#{content_file}",
                                measure: measure },
                    }
                  end
                else
                  {
                    partial: 'measures/measure_condition_modal_default',
                    locals: { measure: measure },
                  }
                end

      new(options: options)
    end

    private

    def config_for(goods_nomenclature_item_id, additional_code, measure_type_id)
      measure_condition_to_augment = config.find do |entry|
        entry['goods_nomenclature_item_id'] == goods_nomenclature_item_id &&
          entry['additional_code'] == additional_code &&
          entry['measure_type_id'] == measure_type_id
      end

      measure_condition_to_augment || DEFAULT_CONFIG_ENTRY
    end

    def config
      @config ||= YAML.load_file(Rails.root.join(CONFIG_FILE_NAME))
    end
  end
end
