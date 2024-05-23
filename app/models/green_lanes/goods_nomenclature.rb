require 'api_entity'

class GreenLanes::GoodsNomenclature
  include XiOnlyApiEntity

  attr_accessor :goods_nomenclature_item_id,
                :description,
                :formatted_description,
                :validity_start_date,
                :validity_end_date,
                :description_plain,
                :producline_suffix

  has_many :applicable_category_assessments, class_name: 'GreenLanes::CategoryAssessment'

  def all(_opts = {})
    raise NoMethodError, 'This method is not implemented'
  end

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

  def category
    # TODO: complete cat_1 and cat_2
    if applicable_category_assessments.empty?
      :cat_3
    end
  end
end
