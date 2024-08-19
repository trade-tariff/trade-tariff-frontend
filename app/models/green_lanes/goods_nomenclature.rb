require 'api_entity'

class GreenLanes::GoodsNomenclature
  include XiOnlyApiEntity
  include Classifiable

  attr_accessor :goods_nomenclature_item_id,
                :description,
                :formatted_description,
                :validity_start_date,
                :validity_end_date,
                :description_plain,
                :producline_suffix

  has_many :applicable_category_assessments, class_name: 'GreenLanes::CategoryAssessment'

  has_many :ancestors, class_name: 'GreenLanes::GoodsNomenclature'
  has_many :descendants, class_name: 'GreenLanes::GoodsNomenclature'

  def filter_by_category(category)
    grouped_assessments[category.to_i] || []
  end

  def primary_assessments_group
    grouped_assessments.first&.second || []
  end

  def grouped_assessments
    @grouped_assessments ||= \
      Hash[applicable_category_assessments.group_by(&:category)
                                          .transform_keys(&:to_i)
                                          .sort]
  end

  def declarable?
    producline_suffix == '80'
  end

  def get_declarable
    return self if declarable?

    descendants.find(&:declarable?)
  end
end
